require 'digest/sha1'
class Account < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  serialize                 :modules
  
  validates_presence_of     :name, :surname, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  before_save               :encrypt_password
  
  def after_create
    Notifier.deliver_registration(self)
  end
  
  def full_name
    "#{name} #{surname}".strip
  end
  
  def modules
    read_attribute(:modules) || []
  end
  
  def modules=(perms)
    perms = perms.collect {|p| p.to_sym unless p.blank? }.compact if perms
    write_attribute(:modules, perms)
  end
  
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
  end

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ?', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    enc = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
    enc.encrypt(salt)
    data = enc.update(password)
    Base64.encode64(data << enc.final)
  rescue
    nil
  end

  def password_clean
    unless @password
      enc = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
      enc.decrypt(salt)
      text = enc.update(Base64.decode64(crypted_password))
      @password = (text << enc.final)
    end
    @password
  rescue
    nil
  end
  
  def active?
    # If you want you can integrate you custom activation/blocking system
    true
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  
  def maps
    if modules && modules.split(",").size > 0
      maps = AccountAccess.find_by_project_modules(modules.split(","))
      return maps unless maps.blank?
    end
    
    if !role.blank?
      maps = AccountAccess.find_by_role(role)
      return maps unless maps.blank?
    end
  end
    
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end