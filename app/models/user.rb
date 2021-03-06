require 'valid_email'
require 'bcrypt'

class User < ActiveRecord::Base
	has_many :comments
	has_many :relevance

	has_one :rating

	attr_accessor :password, :password_confirmation, :new_password, :document
	before_save :encrypt_password

	validates :username, uniqueness: true, presence: true
	validates :email, uniqueness: true, presence: true, email: true
	validates :password, presence: true
	validates :password_confirmation, presence: true
	validates :new_password, presence: true, :on => [:updatePassword]

	def self.authenticate(username, password)
		user = find_by_username_and_account_status(username,true)

		if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
			user
		else
			nil
		end
	end

	def encrypt_password
	    if password.present?
			self.password_salt = BCrypt::Engine.generate_salt
			self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
	    end
  	end
end
