# Code Review - EventNest API

This review document outlines the top 7 issues identified in the EventNest API, prioritized by business impact.

---

## 1. SQL Injection Vulnerability (Security)
**Reference:** [events_controller.rb:10](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/events_controller.rb#L10)  
**Severity:** Critical  

**Description:**  
The search parameter is directly interpolated into a SQL LIKE query without sanitization. An attacker can use this to bypass filters, access draft events, or potentially extract sensitive data from other tables using UNION-based attacks.

**Recommended Fix:**  
Use parameterized queries to allow ActiveRecord to handle sanitization:
```ruby
events = events.where("title LIKE ? OR description LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
```

**Proof of Bug:**
```bash
# Injection to bypass search and potentially access unintended rows
curl -s "http://localhost:3001/api/v1/events?search=%27%20OR%20status%20%3D%20%27draft%27%20OR%20%271%27%3D%271"
```
*Response shows all events in the system regardless of the search term.*

---

## 2. Global Information Leakage (Security)
**Reference:** [orders_controller.rb:6](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/orders_controller.rb#L6)  
**Severity:** Critical  

**Description:**  
The `index` action fetches all orders in the entire system (`Order.all`) instead of scoping them to the authenticated user. This allows any user to view the full purchase history, confirmation numbers, and total spending of every other customer in the database.

**Recommended Fix:**  
Scope the query to the `current_user`:
```ruby
orders = current_user.orders.order(created_at: :desc)
```

**Proof of Bug:**
```bash
# Login as attendee1, then fetch all orders
curl -s -H "Authorization: Bearer <TOKEN>" http://localhost:3001/api/v1/orders
```
*Response shows 4 orders, even though attendee1 only placed 2 of them.*

---

## 3. Broken Access Control - Unauthorized Modification (Security)
**Reference:** [events_controller.rb:90, 100](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/events_controller.rb#L90) / [orders_controller.rb:81](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/orders_controller.rb#L81)  
**Severity:** Critical  

**Description:**  
The `update`, `destroy`, and `cancel` actions perform direct `find(params[:id])` lookups without verifying ownership. Any authenticated user (even an attendee) can modify or delete any event, or cancel another user's order by simply guessing or iterating through IDs.

**Recommended Fix:**  
Standardize on scoped lookups:
```ruby
# In EventsController
event = current_user.events.find(params[:id])
# In OrdersController
order = current_user.orders.find(params[:id])
```

---

## 4. Race Condition in Inventory Management (Data Integrity)
**Reference:** [ticket_tier.rb:17-24](file:///Users/ashokrathod/Documents/eventnest-assessment/app/models/ticket_tier.rb#L17-L24)  
**Severity:** Critical  

**Description:**  
The `reserve_tickets!` method performs a "check-then-act" operation (`if available_quantity >= count ... save!`) without database-level locking. In a high-concurrency event launch, two threads can check the same inventory simultaneously and both conclude they can sell the last ticket, resulting in overselling.

**Recommended Fix:**  
Use pessimistic locking to serialize inventory updates:
```ruby
def reserve_tickets!(count)
  with_lock do
    if available_quantity >= count
      update!(sold_count: sold_count + count)
    else
      raise "Not enough tickets available"
    end
  end
end
```

---

## 5. Cross-Event Ticket Association (Data Integrity)
**Reference:** [orders_controller.rb:52-63](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/orders_controller.rb#L52-L63)  
**Severity:** High  

**Description:**  
The order creation logic does not verify that the provided `ticket_tier_id` belongs to the `event_id` specified in the request. An attacker could potentially buy an inexpensive ticket for "Event A" and associate it with "Event B" in a single request, leading to financial loss and corrupted event data.

**Recommended Fix:**  
Add a verification step during item building:
```ruby
tier = TicketTier.find(item_data[:ticket_tier_id])
raise "Invalid ticket tier" unless tier.event_id == event.id
```

---

## 6. N+1 Query Performance Degradation (Performance)
**Reference:** [events_controller.rb:7, 23-45](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/events_controller.rb#L7) / [orders_controller.rb:6, 8-18](file:///Users/ashokrathod/Documents/eventnest-assessment/app/controllers/api/v1/orders_controller.rb#L6)  
**Severity:** High  

**Description:**  
The index actions for both Events and Orders fetch a list of records and then lazily load associations (user, event, ticket_tiers) for every single record during JSON rendering. For a large set of events, this results in hundreds of database round-trips, significantly impacting API latency.

**Recommended Fix:**  
Use eager loading in the controller:
```ruby
events = Event.published.upcoming.includes(:user, :ticket_tiers)
orders = current_user.orders.includes(:event, :order_items).order(created_at: :desc)
```

---

## 7. Blocking Synchronous Callbacks (Performance)
**Reference:** [event.rb:31](file:///Users/ashokrathod/Documents/eventnest-assessment/app/models/event.rb#L31)  
**Severity:** Medium  

**Description:**  
The `geocode_venue` method is called as a `before_save` synchronous callback and includes a hardcoded `sleep(0.1)`. This intentionally slows down every save operation and blocks the web server's request thread, reducing the overall throughput of the application under load.

**Recommended Fix:**  
Remove the artificial delay and move any real geocoding logic to an asynchronous background job:
```ruby
# In Event model
after_commit :trigger_geocoding, on: [:create, :update]

def trigger_geocoding
  GeocodeVenueJob.perform_later(self.id) if saved_change_to_venue?
end
```
