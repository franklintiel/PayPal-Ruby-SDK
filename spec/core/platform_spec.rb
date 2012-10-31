require 'spec_helper'

describe PayPal::SDK::Core::API::Platform do

  Platform  = PayPal::SDK::Core::API::Platform
  ConvertCurrencyParams = {
          "baseAmountList"        => { "currency" => [ { "code" => "USD", "amount" => "2.0"} ]},
          "convertToCurrencyList" => { "currencyCode" => ["GBP"] } }

  it "create client with Service name" do
    client = Platform.new("AdaptivePayments")
    client.uri.path.should match "AdaptivePayments$"
  end

  it "make API request" do
    client   = Platform.new("AdaptivePayments")
    response = client.request("ConvertCurrency", ConvertCurrencyParams)
    response.should_not be_nil
    response["responseEnvelope"].should_not be_nil
    response["responseEnvelope"]["ack"].should eql "Success"
  end

  it "make API request with certificate authentication" do
    client   = Platform.new("AdaptivePayments", :with_certificate)
    response = client.request("ConvertCurrency", ConvertCurrencyParams)
    response.should_not be_nil
    response["responseEnvelope"].should_not be_nil
    response["responseEnvelope"]["ack"].should eql "Success"
  end

  it "make API request with oauth token" do
    client   = Platform.new("Invoice", :with_oauth_token )
    response = client.request("CreateInvoice", "invoice" => {"merchantEmail"=>"platfo_1255170694_biz@gmail.com", "payerEmail"=>"sender@yahoo.com", "item_name1"=>"item1", "item_quantity1"=>"1", "item_unitPrice1"=>"1.00", "item_name2"=>"item2", "item_quantity2"=>"2", "item_unitPrice2"=>"2.00", "currencyCode"=>"USD", "paymentTerms"=>"DueOnReceipt"} )
    response.should_not be_nil
    response["responseEnvelope"].should_not be_nil
    response["responseEnvelope"]["ack"].should eql "Success"
  end

  it "make API request with proxy" do
    client   = Platform.new("AdaptivePayments", :with_proxy)
    response = client.request("ConvertCurrency", ConvertCurrencyParams)
    response.should_not be_nil
    response["responseEnvelope"].should_not be_nil
    response["responseEnvelope"]["ack"].should eql "Success"
  end

  describe "Failure request" do

    def should_be_failure(response, message = nil)
      response.should_not be_nil
      response["responseEnvelope"].should_not be_nil
      response["responseEnvelope"]["ack"].should eql "Failure"
      response["error"][0]["message"].should match message if message
    end

    it "invalid 3 token authentication" do
      client   = Platform.new("AdaptivePayments", :username => "invalid")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Authentication failed")
    end

    it "invalid ssl certificate authentication" do
      client   = Platform.new("AdaptivePayments", :with_certificate, :username => "invalid")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Authentication failed")
    end

    it "invalid end point" do
      client   = Platform.new(:platform_end_point => "https://svcs-invalid.sandbox.paypal.com/AdaptivePayments")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response)
    end

    it "with soap endpoint" do
      client   = Platform.new(:platform_end_point => "https://api-3t.sandbox.paypal.com/2.0/")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "Not Found")
    end

    it "invalid service" do
      client   = Platform.new("InvalidService")
      response = client.request("ConvertCurrency", ConvertCurrencyParams )
      should_be_failure(response, "An established connection was aborted")
    end

    it "invalid action" do
      client   = Platform.new("AdaptivePayments")
      response = client.request("InvalidAction", ConvertCurrencyParams)
      should_be_failure(response, "Internal Server Error")
    end

    it "invalid params" do
      client   = Platform.new("AdaptivePayments")
      response = client.request("ConvertCurrency", { "inValidCurrencyParams" => {} })
      should_be_failure(response, "Invalid request parameter")
    end

  end

end

