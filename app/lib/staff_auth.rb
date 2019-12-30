# frozen_string_literal: true

class StaffAuth
  def self.check_by_param!(staff_id, auth)
    staff = Staff.find(staff_id)
    auth_correct = create_auth_param(staff)

    raise Pundit::NotAuthorizedError unless auth_correct == auth

    staff
  end

  def self.create_auth_param(staff)
    user = staff.user
    Digest::SHA512.hexdigest([
      user.id,
      user.encrypted_password,
      'vitalize',
      user.email,
      user.locked_at
    ].to_s).last(10)
  end
end
