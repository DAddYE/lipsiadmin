require 'digest/sha1'
require 'openssl'
class Account < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  serialize                 :modules
  
  # Validations
  validates_presence_of     :name, :surname, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_inclusion_of    :role,     :in => AccountAccess.roles

  # Relations
  # go here
  
  # Callbacks
  before_save               :encrypt_password
  after_create              :deliver_registration
  
  # Named Scopes
  # go here
  
  def full_name
    "#{name} #{surname}".strip
  end
  
  # If we don't found a module we need to 
  # to return an empty array
  def modules
    read_attribute(:modules) || []
  end
  
  # We need to perform a little rewrite
  def modules=(perms)
    perms = perms.collect {|p| p.to_sym unless p.blank? }.compact if perms
    write_attribute(:modules, perms)
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
  
  # Get the uncripted password
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
  
  # If you want you can integrate you custom activation/blocking system
  # Our auth system already check this method so don't delete it
  def active?
    true
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # Check if the db password 
  def authenticated?(password)
    crypted_password.chomp == encrypt(password).chomp rescue false
  end
  
  # Generate Methods takes from AccessControl rules
  # Example:
  #
  #   def administrator?
  #     role == "administrator"
  #   end
  AccountAccess.roles.each { |r| define_method("#{r.to_s.downcase.gsub(" ","_").to_sym}?") { role.to_s.downcase == r.to_s.downcase } }
  
protected
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def deliver_registration
    Notifier.deliver_registration(self)
  end
end