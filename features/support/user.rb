class User
  # A method used in features' user records definitions. It accepts a string
  # with a password and the name of a hashing algorithm ('sha1' or 'bcrypt')
  # concatenated with a space. It encrypts user's password using the given
  # mechanism and the given password value.
  def password_with_algorithm=(x)
    pass, algorithm = *x.split
    case algorithm
    when 'bcrypt'
      change_password pass, pass
    when 'sha1'
      self.crypted_password = User.sha1 pass
      self.password = self.password_confirmation = nil
    else
      raise "Unknown hashing algorithm: #{algorithm}"
    end
  end
end
