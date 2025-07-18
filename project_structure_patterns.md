# 🏗️ **ChataHub - Projekt Štruktúra a Design Patterns**

## 📁 **Projekt Štruktúra**

```
chatahub/
├── 📁 app/
│   ├── 📁 controllers/
│   │   ├── application_controller.rb
│   │   ├── reservations_controller.rb
│   │   ├── payments_controller.rb
│   │   ├── photos_controller.rb
│   │   ├── search_controller.rb
│   │   ├── food_items_controller.rb
│   │   └── admin/
│   │       ├── dashboard_controller.rb
│   │       └── analytics_controller.rb
│   │
│   ├── 📁 models/
│   │   ├── application_record.rb
│   │   ├── user.rb
│   │   ├── cabin.rb
│   │   ├── reservation.rb
│   │   ├── payment.rb
│   │   ├── photo.rb
│   │   ├── food_item.rb
│   │   └── concerns/
│   │       ├── searchable.rb
│   │       ├── notifiable.rb
│   │       └── trackable.rb
│   │
│   ├── 📁 services/
│   │   ├── application_service.rb
│   │   ├── reservations/
│   │   │   ├── create_service.rb
│   │   │   ├── cancel_service.rb
│   │   │   └── availability_service.rb
│   │   ├── payments/
│   │   │   ├── process_service.rb
│   │   │   └── stripe_service.rb
│   │   ├── notifications/
│   │   │   ├── sms_service.rb
│   │   │   └── email_service.rb
│   │   ├── search/
│   │   │   ├── index_service.rb
│   │   │   └── query_service.rb
│   │   ├── photos/
│   │   │   ├── upload_service.rb
│   │   │   └── process_service.rb
│   │   ├── weather/
│   │   │   └── fetch_service.rb
│   │   └── calendar/
│   │       └── sync_service.rb
│   │
│   ├── 📁 jobs/
│   │   ├── application_job.rb
│   │   ├── send_sms_notification_job.rb
│   │   ├── sync_calendar_job.rb
│   │   ├── fetch_weather_job.rb
│   │   ├── photo_processing_job.rb
│   │   └── search_index_job.rb
│   │
│   ├── 📁 views/
│   │   ├── layouts/
│   │   │   ├── application.html.erb
│   │   │   └── admin.html.erb
│   │   ├── reservations/
│   │   ├── photos/
│   │   ├── food_items/
│   │   ├── search/
│   │   └── admin/
│   │       ├── dashboard/
│   │       └── analytics/
│   │
│   ├── 📁 javascript/
│   │   ├── controllers/
│   │   │   ├── application.js
│   │   │   ├── calendar_controller.js
│   │   │   ├── photo_upload_controller.js
│   │   │   ├── search_controller.js
│   │   │   ├── darkmode_controller.js
│   │   │   └── food_board_controller.js
│   │   └── src/
│   │       ├── search.js
│   │       └── utils.js
│   │
│   ├── 📁 policies/
│   │   ├── application_policy.rb
│   │   ├── reservation_policy.rb
│   │   ├── photo_policy.rb
│   │   └── admin_policy.rb
│   │
│   └── 📁 lib/
│       ├── notification_handlers/
│       │   ├── base_handler.rb
│       │   ├── sms_handler.rb
│       │   └── email_handler.rb
│       ├── search_builders/
│       │   ├── base_builder.rb
│       │   └── reservation_builder.rb
│       └── metaprogramming/
│           ├── dynamic_validators.rb
│           └── searchable_generator.rb
│
├── 📁 config/
│   ├── routes.rb
│   ├── application.rb
│   ├── database.yml
│   ├── elasticsearch.yml
│   └── initializers/
│       ├── elasticsearch.rb
│       ├── stripe.rb
│       └── twilio.rb
│
├── 📁 db/
│   ├── migrate/
│   └── seeds.rb
│
├── 📁 spec/
│   ├── models/
│   ├── services/
│   ├── controllers/
│   ├── features/
│   └── support/
│
├── 📁 docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── elasticsearch/
│
└── 📁 config/deploy/
    ├── deploy.yml (Kamal)
    └── secrets/
```

---

## 🎯 **Design Patterns Pre ChataHub**

### 1. **Service Object Pattern**
```ruby
# app/services/application_service.rb
class ApplicationService
  def self.call(*args)
    new(*args).call
  end

  private

  def success(data = {})
    ServiceResult.new(success: true, data: data)
  end

  def failure(error)
    ServiceResult.new(success: false, error: error)
  end
end

# app/services/reservations/create_service.rb
class Reservations::CreateService < ApplicationService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    return failure("User has unpaid reservations") if user_has_unpaid_reservations?
    
    reservation = create_reservation
    return failure(reservation.errors) unless reservation.persisted?
    
    process_payment(reservation)
    send_notifications(reservation)
    
    success(reservation: reservation)
  end

  private

  attr_reader :user, :params

  def create_reservation
    @user.reservations.create(@params)
  end

  def process_payment(reservation)
    Payments::ProcessService.call(reservation)
  end

  def send_notifications(reservation)
    Notifications::SmsService.call(reservation, :created)
  end
end
```

### 2. **Factory Pattern pre Notifications**
```ruby
# app/lib/notification_handlers/base_handler.rb
class NotificationHandlers::BaseHandler
  def self.for(type)
    case type
    when :sms
      SmsHandler.new
    when :email
      EmailHandler.new
    else
      raise "Unknown notification type: #{type}"
    end
  end

  def send(reservation, event)
    raise NotImplementedError
  end
end

# Metaprogramovanie pre dynamic handlers
module NotificationHandlers
  def self.register_handler(type, klass)
    @handlers ||= {}
    @handlers[type] = klass
  end

  def self.create_handler(type)
    handler_class = @handlers[type]
    raise "Handler not found for #{type}" unless handler_class
    handler_class.new
  end
end
```

### 3. **Observer Pattern pre Events**
```ruby
# app/models/concerns/notifiable.rb
module Notifiable
  extend ActiveSupport::Concern

  included do
    after_create :trigger_created_event
    after_update :trigger_updated_event
    after_destroy :trigger_destroyed_event
  end

  private

  def trigger_created_event
    EventBus.publish("#{self.class.name.downcase}_created", self)
  end

  def trigger_updated_event
    EventBus.publish("#{self.class.name.downcase}_updated", self)
  end

  def trigger_destroyed_event
    EventBus.publish("#{self.class.name.downcase}_destroyed", self)
  end
end

# app/lib/event_bus.rb
class EventBus
  @subscribers = {}

  def self.subscribe(event_name, &block)
    @subscribers[event_name] ||= []
    @subscribers[event_name] << block
  end

  def self.publish(event_name, data)
    (@subscribers[event_name] || []).each do |subscriber|
      subscriber.call(data)
    end
  end
end
```

### 4. **Builder Pattern pre Search**
```ruby
# app/lib/search_builders/base_builder.rb
class SearchBuilders::BaseBuilder
  def initialize
    @query = {}
  end

  def build
    @query
  end

  def add_filter(field, value)
    @query[:filter] ||= []
    @query[:filter] << { term: { field => value } }
    self
  end

  def add_range(field, from: nil, to: nil)
    range = {}
    range[:gte] = from if from
    range[:lte] = to if to
    
    @query[:filter] ||= []
    @query[:filter] << { range: { field => range } }
    self
  end

  def add_text_search(text)
    @query[:query] = {
      multi_match: {
        query: text,
        fields: searchable_fields
      }
    }
    self
  end

  protected

  def searchable_fields
    raise NotImplementedError
  end
end

# app/lib/search_builders/reservation_builder.rb
class SearchBuilders::ReservationBuilder < SearchBuilders::BaseBuilder
  protected

  def searchable_fields
    ['user.name', 'user.email', 'notes']
  end
end
```

### 5. **Strategy Pattern pre Payments**
```ruby
# app/services/payments/strategy_service.rb
class Payments::StrategyService
  def self.call(payment_method, amount)
    strategy = strategy_for(payment_method)
    strategy.process(amount)
  end

  private

  def self.strategy_for(payment_method)
    case payment_method
    when :apple_pay
      Payments::ApplePayStrategy.new
    when :google_pay
      Payments::GooglePayStrategy.new
    when :card
      Payments::CardStrategy.new
    else
      raise "Unknown payment method: #{payment_method}"
    end
  end
end
```

### 6. **Decorator Pattern pre Photo Processing**
```ruby
# app/lib/photo_decorators/base_decorator.rb
class PhotoDecorators::BaseDecorator
  def initialize(photo)
    @photo = photo
  end

  def process
    @photo
  end

  protected

  attr_reader :photo
end

# app/lib/photo_decorators/resize_decorator.rb
class PhotoDecorators::ResizeDecorator < PhotoDecorators::BaseDecorator
  def initialize(photo, width:, height:)
    super(photo)
    @width = width
    @height = height
  end

  def process
    # Image processing logic
    super
  end
end

# app/lib/photo_decorators/watermark_decorator.rb
class PhotoDecorators::WatermarkDecorator < PhotoDecorators::BaseDecorator
  def process
    # Add watermark logic
    super
  end
end
```

### 7. **Metaprogramovanie pre Searchable**
```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  end

  class_methods do
    def searchable_fields(*fields)
      @searchable_fields = fields
      define_search_methods
    end

    def search_scope(scope_name, &block)
      define_singleton_method("search_#{scope_name}") do |query|
        search_query = instance_exec(query, &block)
        __elasticsearch__.search(search_query)
      end
    end

    private

    def define_search_methods
      @searchable_fields.each do |field|
        define_singleton_method("search_by_#{field}") do |value|
          __elasticsearch__.search(
            query: { match: { field => value } }
          )
        end
      end
    end
  end
end

# Usage v modeloch:
class Reservation < ApplicationRecord
  include Searchable

  searchable_fields :notes, :status
  
  search_scope :by_date_range do |from, to|
    {
      query: {
        range: {
          start_date: { gte: from, lte: to }
        }
      }
    }
  end
end
```

---

## 🎨 **Frontend Architecture (Hotwire + Stimulus)**

### **Stimulus Controllers**
```javascript
// app/javascript/controllers/calendar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["calendar", "selectedDate"]
  static values = { availableDates: Array }

  connect() {
    this.initializeCalendar()
  }

  selectDate(event) {
    const date = event.target.dataset.date
    this.selectedDateTarget.value = date
    this.checkAvailability(date)
  }

  async checkAvailability(date) {
    const response = await fetch(`/reservations/availability?date=${date}`)
    const data = await response.json()
    this.updateCalendar(data)
  }
}
```

### **Turbo Frames pre Modular Updates**
```erb
<!-- app/views/reservations/index.html.erb -->
<%= turbo_frame_tag "reservations" do %>
  <div class="reservations-list">
    <% @reservations.each do |reservation| %>
      <%= turbo_frame_tag "reservation_#{reservation.id}" do %>
        <%= render reservation %>
      <% end %>
    <% end %>
  </div>
<% end %>

<%= turbo_frame_tag "search_results" do %>
  <!-- Search results here -->
<% end %>
```

---

## 🔧 **Výhody Týchto Patterns**

### **Service Objects**
- ✅ Business logic mimo controllerov
- ✅ Testovateľnosť
- ✅ Reusability

### **Factory + Strategy**
- ✅ Flexible handling rôznych typov
- ✅ Easy extension
- ✅ Clean separation of concerns

### **Observer + Event Bus**
- ✅ Decoupled notifications
- ✅ Easy event tracking
- ✅ Extensible architecture

### **Builder Pattern**
- ✅ Complex query building
- ✅ Fluent interface
- ✅ Elasticsearch flexibility

### **Metaprogramovanie**
- ✅ DRY code
- ✅ Dynamic functionality
- ✅ Rails-like DSL

---

## 📋 **Implementation Priority**

### **Phase 1: Core Patterns**
1. Service Objects
2. Basic Policies
3. Simple Concerns

### **Phase 2: Advanced Patterns**
1. Factory for Notifications
2. Builder for Search
3. Strategy for Payments

### **Phase 3: Metaprogramovanie**
1. Dynamic Searchable
2. Event System
3. Advanced Decorators

**Tento setup ti dá perfektný foundation pre extensible, maintainable a professional Rails aplikáciu! 🚀**