class Color
  #include BW::HTTP

  PROPERTIES = [:timestamp, :hex, :id, :tags]
  PROPERTIES.each { |prop|
    attr_accessor prop
  }

  def initialize(hash = {})
    hash.each {|key, value|
      if PROPERTIES.member? key.to_sym
        self.send((key.to_s + "=").to_s, value)
      end
    }
  end

  def tags
    @tags ||= []
  end

  def tags=(tags)
    if tags.first.is_a? Hash
      tags = tags.collect { |tag| Tag.new(tag) }
    end

    tags.each {|tag|
      if not tag.is_a? Tag
        raise "Wrong class for attempted tag #{tag.inspect}"
      end
    }

    @tags = tags
  end

  def self.find(hex, &block)
    BW::HTTP.get("http://www.colr.org/json/color/#{hex}") do |response|

      result_data = BW::JSON.parse(response.body.to_str)
      color_data = result_data["colors"][0]

      color = Color.new(color_data)
      #tests whether a tag is added or not
      puts color.tags.count
      puts
      if color.id.to_i == -1
        block.call(nil)
      else
        block.call(color)
      end

    end
  end

  def add_tag(tag, &block)
    BW::HTTP.post("http://www.colr.org/json/color/#{self.hex}/addtag/", payload: {tags: tag}) do |response|
      p response.body.to_str
      puts
      block.call
    end
  end

end