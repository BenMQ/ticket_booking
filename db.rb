DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Booking
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :email,        String, :required => true
  property :phone,        String, :required => true
  property :school,       String
  property :hostel,       String
  property :address1,     String
  property :address2,     String
  property :zip,          String
  property :ticket1,      Integer, :default => 0
  property :ticket2,      Integer, :default => 0
  property :ticket3,      Integer, :default => 0
  property :payment_method, String
  property :note,         Text
  property :paid,         Boolean, :default => false
  property :placed,       DateTime
  property :delivered,    Boolean, :default => false
end

DataMapper.auto_upgrade!