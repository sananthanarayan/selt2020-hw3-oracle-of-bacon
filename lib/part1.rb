# require 'byebug'              # optional, may be helpful
require 'open-uri'              # allows open('http://...') to return body
require 'cgi'                   # for escaping URIs
require 'nokogiri'              # XML parser
require 'active_model'          # for validations

# The  main class for the OracleOfBacon behaviors
class OracleOfBacon

  class InvalidError < RuntimeError ; end
  class NetworkError < RuntimeError ; end
  class InvalidKeyError < RuntimeError ; end

  attr_accessor :from, :to
  attr_reader :api_key, :response, :uri

  include ActiveModel::Validations
  validates_presence_of :from
  validates_presence_of :to
  validates_presence_of :api_key
  validate :from_does_not_equal_to

  def from_does_not_equal_to
    # TODO: YOUR CODE HERE
  end

 # TODO: FILL IN api_key
  def initialize(api_key = '')
    # TODO: YOUR CODE HERE
  end

  def find_connections
    make_uri_from_arguments
    begin
      xml = URI.parse(uri).read
    rescue OpenURI::HTTPError
      xml = %q{<?xml version="1.0" standalone="no"?>
<error type="unauthorized">unauthorized use of xml interface</error>}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
      Net::ProtocolError => e
      # TODO: YOUR CODE HERE
      # convert all of these into a generic OracleOfBacon::NetworkError,
      #  but keep the original error message
      # your code here
    end
    # TODO: YOUR CODE HERE: create the OracleOfBacon::Response object
  end

  def make_uri_from_arguments
    # TODO: YOUR CODE HERE: set the @uri attribute to properly-escaped URI (hint CGI.escape())
    #   constructed from the @from, @to, @api_key arguments
  end

  class Response
    attr_reader :type, :data
    # create a Response object from a string of XML markup.
    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      parse_response
    end

    private

    def parse_response
      if ! @doc.xpath('/error').empty?
        parse_error_response
      # TODO: YOUR CODE HERE: 'elsif' clauses to handle other responses
      # for responses not matching the 3 basic types, the Response
      # object should have type 'unknown' and data 'unknown response'
      end
    end

    def parse_error_response
      error_type = @doc.xpath('/error').attr("type").value
      error_message = @doc.xpath('/error').text
      if error_type == "unauthorized"
        @type = :unauthorized
        @data = error_message
      elsif error_type == "badinput"
        @type = :badinput
        @data = error_message
      elsif error_type == "unlinkable"
        @type = :unlinkable
        @data = error_message
      else
        @type = :unknown
        @data = "unknown"
      end
    end

    def parse_spellcheck_response
      # TODO: YOUR CODE HERE
    end

    def parse_graph_response
      # TODO: YOUR CODE HERE
    end

    def parse_unknown_response
      # TODO: YOUR COCE HERE
    end
  end
end

