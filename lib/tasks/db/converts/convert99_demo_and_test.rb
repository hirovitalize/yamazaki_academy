# frozen_string_literal: true

require Dir[File.dirname(__FILE__) + '/abstract_convert.rb'].first

unless Rails.env.production?
  module Tasks
    module Db
      module Converts
        class Convert99DemoAndTest < AbstractConvert
          def target_tables
            []
          end

          def convert
            jin_74_as_admin
            wan_22_as_teacher
            hide_privacy_on_students
          end

          private

          # rubocop:disable Rails/SkipsModelValidations
          def hide_privacy_on_students
            Student.where.not(tel: nil).find_each { |s| s.update_columns(tel: '09012345678') }
            Student.where.not(qq: nil).find_each { |s| s.update_columns(qq: "1234#{s.id}12341234") }
            Student.where.not(wechat: nil).find_each { |s| s.update_columns(wechat: "wechat_#{s.id}") }
          end

          def wan_22_as_teacher
            teacher = Staff.includes(:user).find_by(id: 22)
            teacher.user.update_columns(
              email: 'teacher@test.coach',
              encrypted_password: Devise::Encryptor.digest(User, 'password01_coach')
            )
          end

          def jin_74_as_admin
            admin = Staff.includes(:user).find_by(id: 74)
            admin.user.update_columns(
              email: 'admin@test.coach',
              encrypted_password: Devise::Encryptor.digest(User, 'password00_coach')
            )
          end
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
