namespace :auth do
  desc 'Create or update the bootstrap admin user (idempotent)'
  task bootstrap_admin: :environment do
    email = ENV['BOOTSTRAP_ADMIN_EMAIL']&.strip&.downcase
    password = ENV['BOOTSTRAP_ADMIN_PASSWORD']
    name = ENV['BOOTSTRAP_ADMIN_NAME']&.strip.presence || 'Admin'
    role_key = ENV['BOOTSTRAP_ADMIN_ROLE']&.strip.presence || 'super_admin'

    if email.blank? || password.blank?
      raise 'BOOTSTRAP_ADMIN_EMAIL and BOOTSTRAP_ADMIN_PASSWORD are required'
    end

    role = Role.find_by!(key: role_key)

    user = User.find_by(email: email)
    if user
      user.update!(name: name, password: password)
    else
      user = User.create!(
        email: email,
        name: name,
        password: password,
        confirmed_at: Time.current
      )
    end

    UserRole.find_or_create_by!(user: user, role: role)

    user.update!(confirmed_at: Time.current) if user.confirmed_at.blank?
    puts "✅ Bootstrap admin ready: #{user.email} (role: #{role.key})"
  end
end
