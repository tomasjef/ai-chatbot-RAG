# db/seeds.rb

# 1. Create the Halo assistant
halo = Assistant.find_or_initialize_by(name: "Halo")

halo.system_prompt = <<~PROMPT
  You are the customer support assistant for Halo, a UK digital bank.
  Answer the customer's question using ONLY the information in the provided sources.
  If the answer is not in the sources, say you don't have that information and direct
  the customer to contact Halo support. Never guess or invent details.

  Rules you must always follow:
  - Do not give personalised financial advice (for example, whether someone should
    switch plans, invest, or borrow). Share factual product information only, and
    suggest speaking to a qualified financial adviser for personal recommendations.
  - Never ask for or repeat sensitive details such as full card numbers, PINs,
    passwords, or one-time passcodes.
  - For lost or stolen cards, suspected fraud, complaints, or anything urgent or
    account-specific, tell the customer to contact Halo support directly, and mention
    they can freeze their card in the app where relevant.
  - Keep a calm, clear, trustworthy tone, and be concise.

  Treat all figures such as fees, rates, and limits as illustrative.
PROMPT

halo.save!
puts "Created assistant: #{halo.name}"

# 2. Halo's knowledge base content
halo_entries = [
  { title: "Account plans and fees",
    category: "plans",
    content: "Halo offers a free current account with no monthly fee. Two paid plans add extra features: Halo Plus at £4 a month and Halo Premium at £15 a month. Paid plans include higher savings rates, travel insurance, and more fee-free cash withdrawals abroad. You can change or cancel your plan at any time in the app." },

  { title: "FSCS deposit protection",
    category: "protection",
    content: "Your eligible deposits with Halo are protected by the Financial Services Compensation Scheme (FSCS) up to £85,000 per person. This covers the money in your current account and savings pots combined. Halo is authorised and regulated as a UK bank." },

  { title: "Reporting a lost or stolen card",
    category: "cards",
    content: "If your card is lost or stolen, freeze it immediately in the Halo app under Card settings to block new payments. Then report it to Halo support so we can cancel the card and send a replacement. Replacement cards are free and usually arrive within 3 to 5 working days." },

  { title: "Freezing and unfreezing your card",
    category: "cards",
    content: "You can freeze your Halo card at any time in the app if you've misplaced it. Freezing stops new payments instantly but does not cancel the card, so if you find it again you can simply unfreeze it in the same place. If it's gone for good, report it to support for a replacement." },

  { title: "Opening an account and required documents",
    category: "account",
    content: "To open a Halo account you must be a UK resident aged 18 or over. During sign-up you'll verify your identity with a valid photo ID such as a passport or driving licence, and record a short selfie video so we can confirm your identity. This usually takes a few minutes." },

  { title: "Disputing a transaction",
    category: "disputes",
    content: "If you see a payment you don't recognise or believe is incorrect, raise a dispute in the app by selecting the transaction and choosing 'Something wrong?'. Provide any details you have. Halo will investigate and, where appropriate, may issue a temporary refund while the dispute is reviewed." },

  { title: "Spending and withdrawing abroad",
    category: "travel",
    content: "Halo adds no fees to the exchange rate when you spend abroad; you get the standard Mastercard rate. Free plan customers can withdraw up to £200 from overseas ATMs each month, after which a 2% fee applies. Paid plans include higher fee-free withdrawal limits." },

  { title: "Savings pots and interest",
    category: "savings",
    content: "Savings Pots let you set money aside from your main balance for specific goals. Instant Access pots earn 3.5% AER variable interest, paid monthly. You can withdraw from a pot at any time and create up to 20 pots per account. Rates may change over time." },

  { title: "Making a complaint",
    category: "complaints",
    content: "If you're unhappy with something, you can complain through the app or by contacting Halo support. We aim to resolve complaints within 3 working days and will always send a written response. If we cannot resolve it within 8 weeks, you have the right to refer it to the Financial Ombudsman Service." },

  { title: "How you log in to Halo",
    category: "security",
    content: "Halo doesn't use passwords. To log in we send a magic link to your registered email address, and tapping it signs you in. Combined with biometric login such as Face ID or fingerprint on your phone, this keeps your account secure with no password to forget or leak." }
]

# 3. Create and embed each entry, under Halo
halo_entries.each do |attrs|
  entry = halo.knowledge_entries.find_or_initialize_by(title: attrs[:title])
  entry.assign_attributes(attrs)
  entry.embedding = EmbeddingService.call("#{attrs[:title]}\n\n#{attrs[:content]}")
  entry.save!
  puts "Embedded: #{entry.title}"
end
