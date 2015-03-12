require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require_relative 'server'

def app
  Sinatra::Application
end

describe "URL shortener" do
  include Rack::Test::Methods

  describe "Operations on empty set" do
    it "deletes all items" do
      delete '/'
      assert_equal 204, last_response.status
      assert_equal 0, last_response.length
    end

    it "deletes non-existing item" do
      delete '/non-existin-item'
      assert_equal 404, last_response.status
      assert_equal 0, last_response.length
    end

    it "updates non-existing item" do
      put '/non-existin-item'
      assert_equal 404, last_response.status
      assert_equal 0, last_response.length
    end

    it "gets non-existing item" do
      get '/non-existin-item'
      assert_equal 404, last_response.status
      assert_equal 0, last_response.length
    end

    it "requests empty set" do
      get '/'
      assert_equal 200, last_response.status
      assert_equal 0, last_response.length
    end
  end

  describe "Operations on items" do
    describe "Creation of items" do
      it "creates one item" do
        post '/', {:url => "http://google.com"}
        assert_equal 201, last_response.status
        id = last_response.body
        assert_equal 1, id.length
        get "/#{id}"
        assert_equal 301, last_response.status
        assert_equal "http://google.com", last_response.headers["location"]
        delete "#{id}"
        get '/'
        assert_equal 200, last_response.status
        assert_equal '', last_response.body
      end

      it "creates two items" do
        post '/', {:url => "http://google.com"}
        assert_equal 201, last_response.status
        id1 = last_response.body
        assert_equal 1, id1.length
        post '/', {:url => "http://google.nl"}
        assert_equal 201, last_response.status
        id2 = last_response.body
        assert_equal 1, id2.length
        get '/'
        assert_equal 200, last_response.status
        assert_equal [id1, id2].sort,
                     last_response.body.split(',').sort

        get "/#{id1}"
        assert_equal 301, last_response.status
        assert_equal "http://google.com", last_response.headers["location"]
        get "/#{id2}"
        assert_equal last_response.status, 301
        assert_equal "http://google.nl", last_response.headers["location"]

        delete "/#{id1}"
        get '/'
        assert_equal 200, last_response.status
        assert_equal id2, last_response.body
        delete "/#{id2}"
        get '/'
        assert_equal 200, last_response.status
        assert_equal '', last_response.body
      end
    end

    describe "Modifing items" do
      it "modifies one item" do
        post '/', {:url => "http://google.com"}
        id = last_response.body
        put "/#{id}", {:url => "http://google.nl"}
        assert_equal 200, last_response.status

        get "/#{id}"
        assert_equal 301, last_response.status
        assert_equal "http://google.nl", last_response.headers["location"]
        delete '/'
      end
    end
  end
end
