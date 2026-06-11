entries = [
  { title: "Standard shipping times and cost",
    category: "shipping",
    content: "Standard shipping is free on orders over £40, otherwise £3.95. Orders are dispatched within 1 business day and typically arrive in 3 to 5 working days within the UK." },

  { title: "Express and next-day delivery",
    category: "shipping",
    content: "Next-day delivery costs £6.95 and is available on orders placed before 2pm Monday to Friday. Orders placed after the cut-off or at weekends are delivered the next working day." },

  { title: "International shipping",
    category: "shipping",
    content: "We ship to most of Europe. Delivery takes 5 to 10 working days and costs are calculated at checkout based on destination and weight. Customs or import duties are the responsibility of the customer." },

  { title: "Tracking your order",
    category: "shipping",
    content: "Once your order ships you'll receive an email with a tracking link. You can also view tracking by logging into your account and opening the order under Order History." },

  { title: "Return policy and window",
    category: "returns",
    content: "You can return most items within 30 days of delivery for a full refund, as long as they're unused and in their original packaging. Opened software and earphones cannot be returned for hygiene reasons unless faulty." },

  { title: "How to start a return",
    category: "returns",
    content: "Log into your account, open the order, and select Start a Return. Print the prepaid label and drop the parcel at any post office. Returns are free for UK customers." },

  { title: "When refunds are processed",
    category: "returns",
    content: "Refunds are issued to your original payment method within 5 working days of us receiving the returned item. Your bank may take an additional few days to show the funds." },

  { title: "Exchanges",
    category: "returns",
    content: "We don't offer direct exchanges. To swap an item, return the original for a refund and place a new order for the replacement." },

  { title: "Warranty on electronics",
    category: "products",
    content: "All electronics come with a 2-year manufacturer warranty covering faults and defects. This does not cover accidental damage. Keep your order confirmation as proof of purchase." },

  { title: "Product compatibility and specifications",
    category: "products",
    content: "Detailed specifications, including connector types and compatibility, are listed on each product page under the Specifications tab. If you're unsure whether an item suits your device, contact support before ordering." },

  { title: "Changing or cancelling an order",
    category: "orders",
    content: "Orders can be changed or cancelled within 1 hour of being placed, before they enter dispatch. After that, wait for delivery and use the returns process. Manage orders under Order History in your account." },

  { title: "Payment methods accepted",
    category: "orders",
    content: "We accept Visa, Mastercard, American Express, Apple Pay, Google Pay and PayPal. Payment is taken at the point of order. We do not store full card details on our servers." }
]

entries.each do |attrs|
  entry = KnowledgeEntry.find_or_initialize_by(title: attrs[:title])
  entry.assign_attributes(attrs)
  entry.embedding = EmbeddingService.call("#{attrs[:title]}\n\n#{attrs[:content]}")
  entry.save!
  puts "Embedded: #{entry.title}"
end
