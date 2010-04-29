# Convert the values from the date and time picker
# to a date or time class that the datastore can accept
module MultiparameterAssignments
  def self.fix_date(hash, property, type)
    total_attributes = 0
    if Date == type
      total_attributes = 3
    else
      total_attributes = 5
    end
    time_string = ""
    1.upto(total_attributes) do |n|
      if n == 1
        time_string << hash[:"#{property}(#{n}i)"]
      elsif n > 1 && n <= 3
        time_string << '-' + hash[:"#{property}(#{n}i)"]
      elsif n == 4
        time_string << ' ' + hash[:"#{property}(#{n}i)"]
      elsif n > 4
        time_string << ':' + hash[:"#{property}(#{n}i)"]
      end
      hash.delete :"#{property}(#{n}i)"
    end
    hash[property] = type.parse(time_string).send("to_#{type.to_s.downcase}")
    hash
  end
end
