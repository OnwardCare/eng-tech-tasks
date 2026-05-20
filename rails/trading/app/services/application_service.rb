class ApplicationService
  class Result
    attr_reader :data, :errors, :error_type

    def initialize(data: nil, errors: [], error_type: nil)
      @data = data
      @errors = Array(errors)
      @error_type = error_type
    end

    def success?
      @errors.empty?
    end

    def failure?
      @errors.any?
    end
  end

  def self.call(...)
    new(...).call
  end
end
