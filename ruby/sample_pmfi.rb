#!/usr/bin/env ruby -KU -rubygems

require 'json'
require 'net/http'
require 'base64'
require 'openssl'
require 'sinatra'
require 'pp'

enable :sessions

STDOUT.sync = true
DEFAULT_PORT = 3011
set :port, DEFAULT_PORT unless ARGV.include?('-p')

port = Sinatra::Application.port

puts "Open http://localhost:#{port}/ in a browser to use this aample PMFI app"

ONBOARD_URL = 'https://ads.twitter.com/link_managed_account'

MANAGING_PARTNER_SHARED_SECRET = ''      # PUT THE PMFI SHARED_SECRET HERE
MANAGING_PARTNER_CLIENT_ID = ''         # PUT THE WHITELISTED CLIENT_ID HERE
MANAGING_PARTNER_CALLBACK_URL = "http://localhost:#{port}/link_account_callback" # CALLBACK ENDPOINT IN THIS APP, OR CUSTOMIZE AS REQUIRED

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def generate_page
  <<-PAGE
    <html>
    <body>
    <h1>Sample PMFI Onboarding App</h1>
    #{yield}
    </body>
    </html>
  PAGE
end

get '/' do
  generate_page {<<-HTML}
    <p>
    submit this form to start the account link process using your PMFI-enabled application<br/>
    </p>
    <form action="/link_twitter_account" method="GET">
      <label>Twitter user id: <input type="text" name="user_id" value="12345"/></label> (this will be verified against the Twitter user who logs in)<br/>
      <label>fi description: <input type="text" name="fi_description" value="new pmfi"/></label><br/>
      <label>country: <input type="text" name="country" value="GB"/></label><br/>
      <label>currency: <input type="text" name="currency" value="GBP"/></label><br/>
      <label>timezone: <input type="text" name="timezone" value="Europe/London"/></label><br/>
      <input type="submit" value="Link Twitter Account!"/>
    </form>

    <hr>
    <p>Test signature generation</p>
    <form action="/example_signature" method="POST">
      <label>http method: GET</label><br/>
      <label>url: <input type="text" name="url" /></label></br>
      <label>key addition (promotable user id): <input type="text" name="key_addition" /><label><br/>
      <input type="submit" value="Generate Test Signature"/>
    </form>

  HTML
end

get '/link_twitter_account' do
  puts 'in /link_twitter_account'

  session[:promotable_user_id] = params[:user_id]
  redirect to(signed_link_account_url(
    params[:user_id],
    params[:fi_description],
    params[:country],
    params[:currency],
    params[:timezone]))
end

get '/link_account_callback' do
  generate_page { <<-HTML }
    <p>
    Account link result: <strong>#{params[:status]}</strong><br/>
    Signature valid: <strong>#{verify_signature}</strong>
    </p>
    <a href="/">start over</a>
  HTML
end

post '/example_signature' do
  key_addition = params[:key_addition].empty? ? nil : params[:key_addition]

  url_parts = params[:url].split('?')
  base_url = url_parts.first
  query_string = url_parts.last
  param_hash = Rack::Utils.parse_query(query_string)

  pp param_hash
  signature = param_hash.delete('signature')
  parameters = param_hash.sort
  signature = sign('GET', base_url, parameters, key_addition)

  full_url = "#{params[:url]}&signature=#{percent_encode(signature)}"

  generate_page { <<-HTML }
    <p>
    url: <strong>#{h params[:url]}</strong><br/>
    #{key_addition ? ("key addition: <strong>&nbsp;" + key_addition + "</strong></br>") : ""}
    Signature : <strong>#{signature}</strong><br/>
    full url: <strong>#{h full_url}</strong><br/>
    </p>
    <a href="/">start over</a>
  HTML
end

private

def signed_link_account_url(promotable_user_id, fi_description, country, currency, timezone)
  base_url = ONBOARD_URL
  params = [
    [:callback_url, MANAGING_PARTNER_CALLBACK_URL],
    [:client_app_id, MANAGING_PARTNER_CLIENT_ID],
    [:country, country],
    [:currency, currency],
    [:fi_description, fi_description],
    [:promotable_user_id, promotable_user_id.to_s],
    [:timezone, timezone]
  ]

  url = ''
  url << base_url
  url << '?'
  url << params.map do |param|
    "#{param.first}=#{percent_encode(param.last)}"
  end.join('&')
  url << '&signature='
  url << percent_encode(sign('GET', base_url, params))
  url
end

def verify_signature
  url_parts = request.url.split('?')
  base_url = url_parts.first
  query_string = url_parts.last
  param_hash = Rack::Utils.parse_query(query_string)
  signature = param_hash.delete('signature')
  parameters = param_hash.sort
  signature == sign('GET', base_url, parameters, session[:promotable_user_id])
end

def sign(method, base_url, params, key_addition = nil)
  base_string = method.upcase
  base_string << '&'
  base_string << percent_encode(base_url)
  base_string << '&'

  pp params
  encoded_params = params.map do |param|
    param.map { |p| percent_encode(p.to_s) }
  end

  base_string << percent_encode(encoded_params.map do |ep|
    ep.join('=')
  end.join('&'))

  pp base_string

  secret = MANAGING_PARTNER_SHARED_SECRET
  secret = "#{secret}&#{key_addition}" if key_addition
  Base64.encode64("#{OpenSSL::HMAC.digest('sha1', secret, base_string)}").chomp.gsub("\n", '')
end

def percent_encode(string)
  URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).gsub('*', '%2A')
end
