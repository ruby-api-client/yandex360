# frozen_string_literal: true

module Yandex360
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    private

    def validate_required_params(params, required_keys)
      missing_keys = required_keys.reject do |key|
        value = params[key]
        params.key?(key) && !value.nil? && (
          (value.is_a?(String) && !value.strip.empty?) ||
          (value.is_a?(Array) && !value.empty?) ||
          (!value.is_a?(String) && !value.is_a?(Array))
        )
      end
      raise ArgumentError, "Missing required parameters: #{missing_keys.join(', ')}" unless missing_keys.empty?
    end

    def build_url(path_segments)
      "/" + path_segments.compact.join("/")
    end

    def get(url, params: {}, headers: {})
      handle_response client.connection.get(url, params, headers)
    end

    def post(url, body:, headers: {})
      handle_response client.connection.post(url, body, headers)
    end

    def patch(url, body:, headers: {})
      handle_response client.connection.patch(url, body, headers)
    end

    def put(url, body:, headers: {})
      handle_response client.connection.put(url, body, headers)
    end

    def delete(url, params: {}, headers: {})
      handle_response client.connection.delete(url, params, headers)
    end
    alias delete_request delete

    def handle_response(response)
      return response if response.status.between?(200, 299)

      error_message = extract_error_message(response)

      case response.status
      when 400
        raise ValidationError, "Your request was malformed. #{error_message}"
      when 401
        raise AuthenticationError, "You did not supply valid authentication credentials. #{error_message}"
      when 403
        raise AuthorizationError, "You are not allowed to perform that action. #{error_message}"
      when 404
        raise NotFoundError, "No results were found for your request. #{error_message}"
      when 429, 503
        raise RateLimitError, "Your request exceeded the API rate limit. #{error_message}"
      when 500..599
        raise ServerError, "We were unable to perform the request due to server-side problems. #{error_message}"
      else
        raise Error, "Unexpected response status: #{response.status}. #{error_message}"
      end
    end

    def extract_error_message(response)
      return "" unless response.body.is_a?(Hash)

      response.body["error"] || response.body["message"] || ""
    rescue StandardError
      ""
    end
  end
end
