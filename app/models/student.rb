# frozen_string_literal: true

class Student < ApplicationRecord
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail
  include OptimisticLockValidatable

  belongs_to :area
  belongs_to :seller, -> { sales }, class_name: 'Staff', optional: true, inverse_of: :acquired_students
  belongs_to :normalized_student, class_name: 'Student', optional: true

  has_many :lecture_students # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :lectures, through: :lecture_students
  has_many :klass_students, dependent: :destroy
  has_many :klasses, through: :klass_students
  has_many :course_category_students, dependent: :destroy
  has_many :course_categories, through: :course_category_students

  has_many :student_mentors, dependent: :destroy
  has_many :mentors, through: :student_mentors, source: :staff

  has_one :student_mycoach # rubocop:disable Rails/HasManyOrHasOneDependent
  has_one :student_point, dependent: :destroy

  has_many :student_billings # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :student_payments # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :student_commissions # rubocop:disable Rails/HasManyOrHasOneDependent
  has_one :student_balance, dependent: :destroy

  enum sex: { male: 1, female: 2, other: 3 }, _prefix: true
  enum visa_type: ::HashUtil.from_keys(%w[study_abroad family permanent settlement other]), _prefix: true

  scope :normalized, -> { where(normalized: true) }

  validates :tel, length: { in: (0..15) },
                  format: { with: /^[0-9]+$/, multiline: true },
                  allow_blank: true
  validates :qq, length: { in: (0..20) },
                 format: { with: /^[0-9]+$/, multiline: true },
                 allow_blank: true
  validates :wechat, length: { in: (0..20) },
                     format: { with: /^[A-Za-z0-9_-]+$/, multiline: true },
                     allow_blank: true
  validates :contracted_at, timeliness: { type: :date }, allow_blank: true
  validates :code, length: { in: (6..10) },
                   format: { with: /^[A-Z0-9]+$/, multiline: true },
                   uniqueness: { conditions: -> { with_deleted } },
                   presence: true
  %i[yomi yomi_sei yomi_mei].each do |field|
    validates field, format: { with: /^[a-z]+$/, multiline: true },
                     allow_blank: true
  end
  %i[name name_sei name_mei].each do |field|
    validates field, presence: true
  end

  validates :lectures, absence: true, unless: :normalized
  validates :klasses, absence: true, unless: :normalized
  validates :student_billings, absence: true, unless: :normalized

  accepts_nested_attributes_for :student_mentors, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :student_mycoach, reject_if: :all_blank, allow_destroy: true

  delegate :email, to: :student_mycoach

  after_initialize :default_values, if: :new_record?
  before_validation :normalize_names
  before_validation :build_code, if: ->(me) { me.code.blank? }

  def self.not_vip_point
    all.left_outer_joins(:student_point).where('0 > (student_points.total - student_points.reserved)')
  end

  # 購入したコースから入れる全クラス
  def classes_by_courses
    courses_bought_by_student
      .map(&:klass_templates).flatten
      .map { |kt| kt&.klasses }.flatten
      .select { |k| k.finish_date > Time.zone.today }
      .uniq
  end

  # 学生が購入した全コース
  def courses_bought_by_student
    student_billings
      .map(&:student_billing_details).flatten
      .select { |sbd| sbd&.item_type == 'Course' }
      .map(&:item)
  end

  def rebalance!
    transaction do
      build_student_balance if student_balance.blank?
      student_balance.assign_attributes(
        billings_total: student_billings.sum(:total),
        payments_total: student_payments.sum(:settlement_price)
      )
      student_balance.save!
    end
  end

  def similar_students
    student_serch = Student.normalized.where.not(id: id)
    student_serch.where(name_mei: name_mei)
                 .or(student_serch.where.not(tel: '').where(tel: tel))
                 .or(student_serch.where.not(qq: '').where(qq: qq))
                 .or(student_serch.where.not(wechat: '').where(wechat: wechat))
  end

  def merge_into!(master_student)
    master_student.merged_codes = (master_student.merged_codes.to_s.split(',') + [code] + merged_codes.to_s.split(',')).compact.sort.join(',')
    master_student.save!
    self.normalized_student = master_student
    save!
    destroy!
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.import_text_lines(text_lines)
    okubo_area_count = 0
    baba_area_count = 0
    osaka_area_count = 0
    kyoto_area_count = 0

    ModelBulkImporter.student_import(text_lines) do |rows|
      row = rows.split(',')
      next if row[1] == '校舎'

      area = case row[1]
             when '新大久保' then 1
             when '高田馬場' then 2
             when '大阪' then 3
             when '京都' then 4
             end

      sex = case row[6]
            when '男' then :male
            when '女' then :female
            end

      visa_type = case row[12]
                  when '留学' then :study_abroad
                  when '家族' then :family
                  when '永住' then :permanent
                  when '定住' then :settlement
                  when 'その他' then :other
                  end

      sellers = Staff.joins(:staff_roles).where('staff_roles.role_id = ?', 32) # SALESはid:32
      correct_seller = sellers.find { |s| s.name == row[13]&.force_encoding('utf-8')&.strip }
      raise '営業担当が存在しません' if row[13]&.force_encoding('utf-8')&.strip.present? && correct_seller.blank? # 誤った名前が入っている場合

      seller_id = correct_seller.present? ? correct_seller.id : nil

      japanese_school = JapaneseSchool.find { |s| s.name == row[14]&.force_encoding('utf-8')&.strip }
      raise '記入した日本語学校が存在しません' if row[14]&.force_encoding('utf-8')&.strip.present? && japanese_school.blank? # 誤った名前が入っている場合

      japanese_school_id = japanese_school.present? ? japanese_school.id : nil

      klass = Klass.find { |s| s.name == row[15]&.force_encoding('utf-8')&.strip }
      raise '記入したクラスが存在しません' if row[15]&.force_encoding('utf-8')&.strip.present? && klass.blank? # 誤った名前が入っている場合

      klass_id = klass.present? ? klass.id : nil

      okubo_area_count += 1 if area == 1
      baba_area_count += 1 if area == 2
      osaka_area_count += 1 if area == 3
      kyoto_area_count += 1 if area == 4

      prefix = Time.zone.today.strftime('%y') + format('%02d', area)
      max_code = Student.all.with_deleted.ransack(code_start: prefix).result.maximum(:code)

      code = case row[1]
             when '新大久保' then max_code.present? ? (max_code.to_i + okubo_area_count).to_s : (prefix + '0001')
             when '高田馬場' then max_code.present? ? (max_code.to_i + baba_area_count).to_s : (prefix + '0001')
             when '大阪' then max_code.present? ? (max_code.to_i + osaka_area_count).to_s : (prefix + '0001')
             when '京都' then max_code.present? ? (max_code.to_i + kyoto_area_count).to_s : (prefix + '0001')
             end

      student = Student.new(
        code: code,
        area_id: area,
        name_sei: row[2].force_encoding('utf-8'),
        name_mei: row[3].force_encoding('utf-8'),
        yomi_sei: row[4]&.gsub(/[^a-z]/, ''),
        yomi_mei: row[5]&.gsub(/[^a-z]/, ''),
        sex: sex,
        birthday: row[7],
        contracted_at: row[8],
        tel: row[9]&.gsub(/(-|－|‐)/, ''),
        wechat: row[10]&.gsub(/[^0-9A-Za-z_-]/, ''),
        qq: row[11]&.gsub(/[^0-9]/, ''),
        visa_type: visa_type,
        seller_id: seller_id,
        japanese_school_id: japanese_school_id
      )
      student.klass_students.new.klass_id = klass_id
      student.build_student_mycoach.email = row[0]
      student
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def normalize_names
    self.name = ((name_sei.presence || '') + (name_mei.presence || '')).gsub('\s', '')
    self.yomi = ((yomi_sei.presence || '') + (yomi_mei.presence || '')).gsub('\s', '')
  end

  def build_code
    return if area&.code.blank?

    prefix = Time.zone.today.strftime('%y') + format('%02d', area.code.to_i)
    max_code = Student.all.with_deleted.ransack(code_start: prefix).result.maximum(:code)
    self.code = max_code.present? ? (max_code.to_i + 1).to_s : (prefix + '0001')
  end

  def default_values
    self.contracted_at = Time.zone.today if contracted_at.nil?
    self.normalized = true if normalized.blank? && similar_students.blank?
  end
end
