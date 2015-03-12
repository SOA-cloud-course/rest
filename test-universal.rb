if ARGV.length != 1
  puts "Provide address, e.g.:"
  puts "ruby test-universal.rb http://localhost:4567"
  exit
end

require 'minitest/autorun'
require 'minitest/rg'
require 'httpclient'


server = ARGV.first
client = HTTPClient.new

describe "URL shortener" do
  describe "Operations on empty set" do
    it "deletes all items" do
      response = client.delete "#{server}/"
      assert_equal 204, response.code
      assert_equal 0, response.body.length
    end

    it "deletes non-existing item" do
      response = client.delete "#{server}/non-existin-item"
      assert_equal 404, response.code
      assert_equal 0, response.body.length
    end

    it "updates non-existing item" do
      response = client.put "#{server}/non-existin-item", {:url => "http://foo.bar.com"}
      assert_equal 404, response.code
      assert_equal 0, response.body.length
    end

    it "gets non-existing item" do
      response = client.get "#{server}/non-existin-item"
      assert_equal 404, response.code
      assert_equal 0, response.body.length
    end

    it "requests empty set" do
      client.delete "#{server}/"
      response = client.get "#{server}/"
      assert_equal 200, response.code
      assert_equal 0, response.body.length
    end
  end

  describe "Operations on items" do
    describe "Creation of items" do
      it "creates one item" do
        client.delete "#{server}/"

        response = client.post "#{server}/", {:url => "http://google.com"}
        assert_equal 201, response.code
        id = response.body
        assert_equal 1, id.length
        response = client.get "#{server}/#{id}"
        assert_equal 301, response.code
        assert_equal "http://google.com", response.headers["Location"]
        response = client.delete "#{server}/#{id}"
        response = client.get "#{server}/"
        assert_equal 200, response.code
        assert_equal '', response.body
      end

      it "creates two items" do
        client.delete "#{server}/"

        response = client.post "#{server}/", {:url => "http://google.com"}
        assert_equal 201, response.code
        id1 = response.body
        assert_equal 1, id1.length
        response = client.post "#{server}/", {:url => "http://google.nl"}
        assert_equal 201, response.code
        id2 = response.body
        assert_equal 1, id2.length
        response = client.get "#{server}/"
        assert_equal 200, response.code
        assert_equal [id1, id2].sort,
                     response.body.split(',').sort
        response = client.get "#{server}/#{id1}"
        assert_equal 301, response.code
        assert_equal "http://google.com", response.headers["Location"]
        response = client.get "#{server}/#{id2}"
        assert_equal 301, response.code
        assert_equal "http://google.nl", response.headers["Location"]

        response = client.delete "#{server}/#{id1}"
        response = client.get "#{server}/"
        assert_equal 200, response.code
        assert_equal id2, response.body
        response = client.delete "#{server}/#{id2}"
        response = client.get "#{server}/"
        assert_equal 200, response.code
        assert_equal '', response.body
      end
    end

    describe "Modifing items" do
      it "modifies one item" do
        client.delete "#{server}/"

        response = client.post "#{server}/", {:url => "http://google.com"}
        id = response.body
        response = client.put "#{server}/#{id}", {:url => "http://google.nl"}
        assert_equal 200, response.code
        response = client.get "#{server}/#{id}"
        assert_equal 301, response.code
        assert_equal "http://google.nl", response.headers["Location"]
        response = client.delete "#{server}/"
      end
    end
  end
end
