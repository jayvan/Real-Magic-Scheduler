# == Schema Information
# Schema version: 20110222181535
#
# Table name: users
#
#  id                 :integer         primary key
#  first_name         :string(255)
#  email              :string(255)
#  created_at         :timestamp
#  updated_at         :timestamp
#  encrypted_password :string(255)
#  salt               :string(255)
#  last_name          :string(255)
#  admin              :boolean
#  primary            :boolean
#  disabled           :boolean
#

require 'digest'
class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :username
	
	before_save :encrypt_password
	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :first_name, :presence => true
	validates :last_name, :presence => true
	validates :email, :presence => true,
										:format => { :with => email_regex },
										:uniqueness => { :case_sensitive => false }
											 
  has_many :shifts, :class_name => "Shift", :finder_sql => 'SELECT * FROM shifts WHERE shifts.primary_id = #{id} OR shifts.secondary_id = #{id} ORDER BY shifts.start'
  
  default_scope :order => 'users.last_name ASC'
  
	def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
	def has_password?(submitted_password)
		encrypt(submitted_password) == encrypted_password
	end					 
	
	def full_name
	  "#{first_name} #{last_name}"
	end
	
	def name
	  "#{first_name} #{last_name[0,1]}."
	end
						
	def admin?
	  admin
	end
	
	def primary?
	  primary
	end
	
	def past_shifts
	  shifts.select { |shift| shift.start <= Time.zone.now }
	end
	
	def current_shifts
	  shifts.select { |shift| shift.start > Time.zone.now }
	end
	
	def hours(type)
	  past_shifts.inject(0){|sum, shift| shift.shift_type == type ? sum + shift.length : sum}
	end
	
	def upcoming_hours(type)
	  current_shifts.inject(0){|sum, shift| shift.shift_type == type ? sum + shift.length : sum}
	end
	
	def total_hours(type)
	  hours(type) + upcoming_hours(type)
	end
	
	def hours_quota(type)
	  primary ? type.primary_requirement : type.secondary_requirement
	end
						
	private
	  
	  def encrypt_password
	    if (self.password != nil)
        self.salt = make_salt if new_record?
        self.encrypted_password = encrypt(password)
      end
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end 
end
