# require 'byebug'              # optional, may be helpful
require 'open-uri'              # allows open('http://...') to return body
require 'cgi'                   # for escaping URIs
require 'nokogiri'              # XML parser
require 'active_model'          # for validations

# The  main class for the OracleOfBacon behaviors
class OracleOfBacon

  class InvalidError < RuntimeError; end
  class NetworkError < RuntimeError; end
  class InvalidKeyError < RuntimeError; end

  attr_accessor :from, :to
  attr_reader :api_key, :response, :uri

  include ActiveModel::Validations
  validates_presence_of :from
  validates_presence_of :to
  validates_presence_of :api_key
  validate :from_does_not_equal_to

  # Default Actor
  # Could just initialize to and from to equal Kevin Bacon separately but its better coding practice to save Kevin Bacon
  # as string to a variable and set to and from to that variable
  DEF_PERSON = 'Kevin Bacon'

  def from_does_not_equal_to
    # TODO: YOUR CODE HERE
    # Need to make sure from and to don't equal each other since user is not trying to connect actor to themselves
    # Need to initialize err variable since its not the same as network errors. Had that issue before since I was assuming
    # that the errors variable from ActiveModel would be substituted for one of the network errors
    errors.add(:from, 'from and to cannot be equal to each other') if to == from
  end

  # TODO: FILL IN api_key
  def initialize(api_key = '38b99ce9ec87')
    # TODO: YOUR CODE HERE
    # Initializing the variables
    @api_key = api_key
    @to = DEF_PERSON
    @from = DEF_PERSON
    @uri = nil
    @response = nil
  end

  def find_connections
    make_uri_from_arguments
    begin
      xml = URI.parse(uri).read
      # TODO: YOUR CODE HERE
      # convert all of these into a generic OracleOfBacon::NetworkError, but keep the original error message your code here
      # Consolidated all network errors in one line to be used instead of using them separately with multiple lines
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError => e
      raise NetworkError, e.message
    end
    # TODO: YOUR CODE HERE: create the OracleOfBacon::Response object
    @response = Response.new(xml)
  end

  def make_uri_from_arguments
    # TODO: YOUR CODE HERE: set the @uri attribute to properly-escaped URI (hint CGI.escape())
    #   constructed from the @from, @to, @api_key arguments
    # Used this link to figure out how to use CGI method https://ruby-doc.org/stdlib-2.4.3/libdoc/cgi/rdoc/CGI/Util.html#method-i-escape
    # After reading the ruby documentation CGI link about 20 times, realized I was calling the CGI escape function in the wrong spot, need to call it
    # individually for each of the three arguments not for the entire line
    @uri = "http://oracleofbacon.org/cgi-bin/xml?p=#{CGI.escape(api_key)}&a=#{CGI.escape(to)}&b=#{CGI.escape(from)}"
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
      if !@doc.xpath('/error').empty?
        parse_error_response
      # TODO: YOUR CODE HERE: 'elsif' clauses to handle other responses
      # for responses not matching the 3 basic types, the Response
      # object should have type 'unknown' and data 'unknown response'
      elsif !@doc.xpath('/link').empty?
        parse_graph_response
      elsif !@doc.xpath('/spellcheck').empty?
        parse_spellcheck_response
      else
        parse_unknown_response
      end
    end

    def parse_error_response
      error_type = @doc.xpath('/error').attr('type').value
      error_message = @doc.xpath('/error').text
      if error_type == 'unauthorized'
        @type = :unauthorized
        @data = error_message
      elsif error_type == 'badinput'
        @type = :badinput
        @data = error_message
      elsif error_type == 'unlinkable'
        @type = :unlinkable
        @data = error_message
      else
        @type = :unknown
        @data = 'unknown response'
      end
    end

    # Used this https://ruby-doc.org/stdlib-2.4.1/libdoc/rexml/rdoc/REXML/XPath.html to learn about XPath
    def parse_spellcheck_response
      # TODO: YOUR CODE HERE
      @type = :spellcheck
      @data = @doc.xpath('//match').map(&:text)
    end

    def parse_graph_response
      # TODO: YOUR CODE HERE
      @type = :graph
      @data = actor.zip(movie).flatten.compact.map(&:text)
    end

    def parse_unknown_response
      # TODO: YOUR CODE HERE
      @type = :unknown
      @data = 'Cannot find response'
    end

    # Define actor method
    def actor
      @doc.xpath('//actor')
    end

    # Define movie method
    def movie
      @doc.xpath('//movie')
    end

  end
end

