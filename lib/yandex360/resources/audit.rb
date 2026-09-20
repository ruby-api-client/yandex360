# frozen_string_literal: true

module Yandex360
  # Mail and Disk audit logs.
  #
  # These are two separate endpoints and they page by opaque token rather than
  # page number, so there is no combined listing and no page argument.
  #
  # See https://yandex.ru/dev/api360/doc/ru/ref/AuditLogService/
  class AuditResource < Resource
    # Events per page; the API caps this at 100.
    MAX_PAGE_SIZE = 100

    # Accepts the documented filters as extra keywords: after_date, before_date,
    # include_uids, exclude_uids and, for mail, types.
    def mail(org_id:, page_size: MAX_PAGE_SIZE, page_token: nil, **filters)
      events(org_id: org_id, log: "mail", page_size: page_size, page_token: page_token, **filters)
    end

    def disk(org_id:, page_size: MAX_PAGE_SIZE, page_token: nil, **filters)
      events(org_id: org_id, log: "disk", page_size: page_size, page_token: page_token, **filters)
    end

    private

    def events(org_id:, log:, page_size:, page_token:, **filters)
      validate_required_params({org_id: org_id}, [:org_id])
      params = {pageSize: page_size}.merge(camelize(filters))
      params[:pageToken] = page_token unless page_token.nil?

      resp = get("/security/v1/org/#{org_id}/audit_log/#{log}", params: params)
      Collection.from_response(resp, key: "events", type: AuditEvent) do |token|
        events(org_id: org_id, log: log, page_size: page_size, page_token: token, **filters)
      end
    end

    # The filters are documented in camelCase; accept snake_case and convert,
    # so callers are not the only ones spelling afterDate by hand.
    def camelize(filters)
      filters.transform_keys do |key|
        head, *rest = key.to_s.split("_")
        [head, *rest.map(&:capitalize)].join.to_sym
      end
    end
  end
end
