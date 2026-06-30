#!/usr/bin/env ruby

require "fileutils"

OUTPUT_DIR = File.expand_path("../db/source_pdfs/halo", __dir__)

DOCS = {
  "halo_current_account_terms_and_conditions.pdf" => {
    title: "HALO Current Account Terms and Conditions",
    body: [
      "Prototype note: HALO is fictional demo content modelled on the structure of UK digital current-account terms, fee information, support articles, and deposit-protection disclosures.",
      "",
      "These terms and using your HALO account",
      "These terms apply to the HALO Everyday Current Account. The account is for personal use only and must not be used for business purposes. The customer must be at least 18, a UK resident, and able to complete identity and eligibility checks before the account can be opened.",
      "The customer agrees to these terms by opening the account, using the HALO app, using a HALO card, making or receiving payments, or keeping money with HALO. HALO may refuse an application, pause onboarding, or ask for more information where identity, fraud, sanctions, credit, or regulatory checks require it.",
      "",
      "How to contact HALO",
      "Customers can contact HALO through in-app chat, by email at support@halo.example, or by phone on 0800 000 4821 from the UK. HALO can contact customers through the app, push notification, email, phone, SMS, or post. The customer must keep their phone number, email address, and home address up to date.",
      "HALO sends statements, notices, payment alerts, and changes to terms in English. Monthly statements are available in the app. Customers can download statements and transaction history at any time while the account remains open.",
      "",
      "Keeping the account and app secure",
      "The customer must keep their phone, HALO app, password, passcode, PIN, card details, and security credentials safe. The customer must not share their app login, PIN, one-time codes, card number, CVC, or remote access to their device with anyone.",
      "HALO will never ask for the customer's full card number, CVC, app passcode, or PIN in chat, email, or by phone. If the customer thinks someone else knows their details, they should freeze the card, change their passcode, and contact HALO immediately.",
      "The customer is responsible for checking transactions regularly and telling HALO as soon as possible about unauthorised transactions, errors, lost devices, lost cards, suspicious calls, scams, or security concerns.",
      "",
      "Available balance, Pots, and overdrafts",
      "The main available balance is the amount used to decide whether payments can go through. Money in Pots and savings spaces belongs to the customer but is not part of the main available balance until moved back.",
      "HALO may reject a payment if the main available balance is too low, even if money is held in a Pot. Offline card payments, delayed merchant collections, chargeback reversals, fees, or corrections can still take the account below zero. Any unarranged negative balance is due immediately.",
      "HALO does not offer an arranged overdraft in this prototype account. If an overdraft product is added later, separate overdraft terms, rates, eligibility checks, and repayment information will apply.",
      "",
      "Payments and payment instructions",
      "The customer can make bank transfers, standing orders, Direct Debits, card payments, cash withdrawals, international payments, and internal transfers where those features are available in the app.",
      "To send a UK bank transfer, HALO may need the recipient name, sort code, account number, account type, amount, reference, and payment date. The customer approves payments using the app passcode, PIN, security code, fingerprint, face recognition, or another security method.",
      "Once a customer has approved an immediate payment, it usually cannot be cancelled. Future-dated payments and standing orders can be cancelled in the app before the cut-off shown. Direct Debits must normally be cancelled at least 2 working days before the due date.",
      "HALO may refuse, delay, reverse, or block a payment where instructions are unclear, the payment exceeds limits, there is not enough available balance, fraud or scam risk is suspected, the account is restricted, or legal, sanctions, regulatory, or partner-bank rules require it.",
      "",
      "International payments and foreign currency",
      "International payments may require recipient bank details such as an IBAN, BIC, routing number, address, account type, currency, and payment purpose. The exact information depends on destination and currency.",
      "International payments show the exchange rate, estimated arrival time, fixed fee, variable fee, and any partner charges before confirmation. After approval, international payments normally cannot be cancelled, though HALO may try to recall a payment where possible.",
      "Card spending in a foreign currency uses the card scheme exchange rate unless otherwise shown. HALO does not add a card purchase fee in this prototype. ATM operators, foreign banks, or intermediary banks may charge their own fees.",
      "",
      "Fees, interest, and charges",
      "The Everyday Current Account has no monthly fee. UK bank transfers, incoming GBP payments, card purchases, statements, and app notifications are free. Specific services, such as lost-card replacement, express card delivery, international payments, or specialist document requests, may carry a fee shown before the customer confirms.",
      "HALO does not pay interest on the Everyday Current Account balance in this prototype. Separate savings products may pay interest and have their own terms.",
      "HALO may take fees, refunds owed back to HALO, unpaid debts, chargeback reversals, or mistaken credits from the account balance, Pots, or savings spaces where permitted by law and these terms.",
      "",
      "Cards and card controls",
      "The HALO card can be used anywhere the card network is accepted, subject to account status, card controls, merchant acceptance, security checks, available balance, and payment limits.",
      "Customers can freeze and unfreeze the card, view card details, reveal or reset the PIN, block gambling merchants, block cash withdrawals, and order a replacement card in the app where available.",
      "Freezing a card stops most new card payments but may not stop some offline payments, recurring payments, transport charges, delayed merchant collections, hotel or hire deposits, or card payments already authorised.",
      "",
      "Refunds, disputes, scams, and unauthorised payments",
      "If a customer reports an unauthorised payment, HALO will investigate and usually refund the payment unless the customer acted fraudulently, intentionally failed to keep security details safe, or was grossly negligent.",
      "For merchant disputes, customers should usually contact the merchant first unless fraud is suspected. HALO may request receipts, cancellation proof, delivery records, merchant messages, police references, or other evidence before raising a chargeback.",
      "Customers should report payment errors and unauthorised transactions as soon as possible. If the customer waits more than 13 months after the payment date, HALO may not be able to refund or recover the money.",
      "",
      "Account restrictions and account closure",
      "HALO may suspend, freeze, restrict, or close an account if required by law, if fraud or criminal activity is suspected, if the customer breaches these terms, if identity checks fail, if the customer behaves abusively, or if keeping the account open would create unacceptable risk.",
      "The customer can ask to close the account in the app. Before closure, the customer must repay any money owed and move out any remaining balance. HALO may keep records after closure where required for legal, regulatory, tax, fraud-prevention, complaint-handling, or audit reasons.",
      "",
      "Changes to these terms",
      "HALO may change these terms, features, fees, limits, interest information, or contact details. HALO will give reasonable notice for changes that are not favourable to customers, unless the change is required sooner for legal, regulatory, security, or operational reasons.",
      "If the customer does not agree to a change, they can close the account before the change takes effect. Continuing to use the account after the change date means the customer accepts the new terms.",
      "",
      "Complaints",
      "If something goes wrong, the customer can complain through in-app chat, email, phone, or post. HALO will acknowledge the complaint, investigate fairly, and send a final response within the timescales required by UK complaint-handling rules.",
      "If the customer is unhappy with HALO's final response, or HALO does not respond in time, the customer may be able to refer the complaint to the Financial Ombudsman Service.",
      "",
      "Deposit protection",
      "Eligible deposits are protected by the UK Financial Services Compensation Scheme up to the applicable statutory limit per eligible depositor, subject to FSCS rules. Protection depends on the authorised bank or deposit-taker holding the money and the customer's eligibility."
    ]
  },
  "halo_account_balance_guide.pdf" => {
    title: "HALO Account and Balance Guide",
    body: [
      "Prototype note: HALO is fictional demo content modelled on UK digital current-account guidance.",
      "",
      "Check my balance",
      "For the demo account, Alex Rivera's available balance is GBP 4,212.86 in Everyday Current Account. Savings Pots total GBP 11,940.02. Pending card activity of GBP 58.20 has not yet posted and is not included in the available balance.",
      "The main available balance is the amount used to decide whether card payments, transfers, Direct Debits, and standing orders can go through. Money in Pots or savings spaces belongs to the customer but does not count as main available balance until it is moved back.",
      "The customer can view the latest balance, transaction feed, scheduled payments, monthly statements, and Pot balances in the HALO app. HALO sends instant notifications when money is spent or received.",
      "",
      "Deposit protection",
      "Eligible HALO deposits are protected by the UK Financial Services Compensation Scheme up to the applicable statutory limit per eligible depositor. The protection applies to qualifying deposits held with the authorised bank partner, subject to FSCS eligibility rules.",
      "If a customer asks whether savings are safe, explain that money in current-account balances and savings spaces may count toward the same compensation limit when held with the same protected institution."
    ]
  },
  "halo_payments_limits_and_fees.pdf" => {
    title: "HALO Payments, Limits and Fees",
    body: [
      "Prototype note: HALO payment rules are fictional, but the structure is inspired by UK digital bank payment terms and fee schedules.",
      "",
      "Transfer limits",
      "The standard daily transfer limit is GBP 25,000 for external UK bank transfers and GBP 50,000 between the customer's own HALO accounts. Limits reset at 00:00 UK time each day.",
      "Customers can see their current payment limits in Settings > Limits. Limits may change over time for security, risk, regulatory, or account-history reasons. HALO may also pause or refuse a payment if instructions are unclear, if a payment goes over the customer's limits, if fraud is suspected, or if a legal or regulatory rule requires it.",
      "A temporary transfer limit increase can be requested in Settings > Limits. HALO may ask for extra verification before raising a limit.",
      "",
      "UK payments",
      "Sending money within the UK by bank transfer is free. Faster Payments usually arrive instantly, but can take up to 2 hours. Other bank transfers usually arrive within 1 working day but may take longer for technical, fraud, legal, or regulatory checks.",
      "To make a UK bank transfer, the customer needs the recipient's name, sort code, account number, and account type. The customer may approve the transfer with a PIN, security code, fingerprint, or face recognition.",
      "",
      "Wire transfer fees",
      "HALO uses the phrase wire transfer for international bank transfers and foreign-currency payments. UK transfers cost GBP 0. International wires show the exchange rate, estimated arrival time, fixed fee, and variable fee in the app before confirmation.",
      "The fixed fee for an international wire is no more than GBP 9. The variable fee is between 0% and 1.80%, depending on destination, currency, route, and payment partner. The exact fee must be shown before the customer approves the transfer.",
      "Incoming payments in GBP are free. Incoming EUR or other foreign-currency payments are converted to GBP before they appear in the account and may have a 1% conversion fee capped at GBP 1,000. The payer's bank or intermediary banks may charge their own fees.",
      "Card payments in a foreign currency are free from HALO. Overseas ATM withdrawals may have a free allowance and then a percentage fee, which is shown in the fee schedule."
    ]
  },
  "halo_cards_pin_and_security.pdf" => {
    title: "HALO Cards, PIN and Security",
    body: [
      "Prototype note: HALO card support is fictional, but follows common UK digital bank card-security patterns.",
      "",
      "Lost or stolen card",
      "If a card is lost, stolen, damaged, or used for transactions the customer does not recognise, the customer should freeze the card immediately in the HALO app and tell HALO as soon as possible.",
      "To replace a lost or damaged card, go to Home > Card > Freeze, then choose Order a new card and select the reason for replacement. If the card was stolen or fraud is suspected, choose I've been a victim of fraud or theft.",
      "If the customer cannot access the HALO app, they can use HALO Web to freeze the card, or contact support by phone or email. The virtual card can remain available for online payments if HALO has not cancelled it for security reasons.",
      "HALO does not charge for replacement cards that expire, arrive faulty, are stolen, are swallowed by an ATM, or are cancelled because HALO is concerned about fraud. HALO may charge GBP 5 for replacement cards that are lost or damaged after the free replacement allowance. Replacement cards sent outside the UK may cost GBP 30.",
      "",
      "Reset my PIN",
      "If a customer forgets their PIN or enters the wrong PIN too many times, they can recover or reset the PIN in the app. Go to Card, choose Reveal PIN or Reset PIN, then complete identity checks such as biometric confirmation or a short selfie video.",
      "HALO will never ask for the customer's PIN, full card number, or three-digit CVC in chat, email, or by phone. The customer should keep the PIN secret, even from HALO staff.",
      "After identity verification, HALO can show the PIN reminder or unblock PIN use. ATM and card-network systems can take up to 30 minutes to reflect a PIN change or unblock."
    ]
  },
  "halo_disputes_refunds_and_chargebacks.pdf" => {
    title: "HALO Disputes, Refunds and Chargebacks",
    body: [
      "Prototype note: HALO disputes content is fictional and modelled on UK current-account refund and card-dispute principles.",
      "",
      "Dispute a charge",
      "If the customer does not recognise a card charge, they should freeze the card first, then open the transaction in the HALO app and choose Help > I don't recognise this transaction. HALO will ask what happened and may request evidence such as receipts, merchant messages, delivery proof, or cancellation confirmation.",
      "The customer should tell HALO as soon as possible. If the customer waits more than 13 months from the date money left the account, HALO may not be able to recover the money.",
      "For merchant disputes, the customer should usually contact the merchant first unless fraud is suspected. HALO can raise a card chargeback where the goods or services were not received, were significantly not as described, the merchant charged twice, the merchant did not provide an agreed refund, or the final amount was higher than reasonably expected.",
      "If a card payment was made before the final amount was known, such as a hotel, hire car, or fuel deposit, and the final amount is higher than the customer could reasonably expect, the customer should report it within 8 weeks and provide requested information.",
      "If a Direct Debit is taken in error by HALO or the company collecting it, the customer is entitled to an immediate refund under the Direct Debit Guarantee.",
      "HALO will usually refund unauthorised payments, payments taken after the card was frozen, and payment losses caused by HALO's own mistake, unless the customer acted fraudulently or failed to keep security details safe."
    ]
  }
}.freeze

class SimplePdf
  PAGE_WIDTH = 612
  PAGE_HEIGHT = 792
  LEFT = 54
  TOP = 742
  LEADING = 15
  LINES_PER_PAGE = 47
  WRAP_WIDTH = 88

  def self.write(path, title, paragraphs)
    new(path, title, paragraphs).write
  end

  def initialize(path, title, paragraphs)
    @path = path
    @title = title
    @paragraphs = paragraphs
  end

  def write
    pages = lines.each_slice(LINES_PER_PAGE).to_a
    objects = []

    catalog_id = add_object(objects, "<< /Type /Catalog /Pages 2 0 R >>")
    pages_id = add_object(objects, nil)
    font_id = add_object(objects, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    page_ids = []

    pages.each do |page_lines|
      stream = page_stream(page_lines)
      content_id = add_object(objects, "<< /Length #{stream.bytesize} >>\nstream\n#{stream}\nendstream")
      page_ids << add_object(objects, "<< /Type /Page /Parent #{pages_id} 0 R /MediaBox [0 0 #{PAGE_WIDTH} #{PAGE_HEIGHT}] /Resources << /Font << /F1 #{font_id} 0 R >> >> /Contents #{content_id} 0 R >>")
    end

    objects[pages_id - 1] = "<< /Type /Pages /Kids [#{page_ids.map { |id| "#{id} 0 R" }.join(' ')}] /Count #{page_ids.length} >>"

    File.binwrite(@path, build_pdf(objects, catalog_id))
  end

  private

  def lines
    wrapped = [ @title, "Generated for HALO demo source retrieval.", "" ]
    @paragraphs.each do |paragraph|
      wrapped.concat(wrap(paragraph.to_s))
      wrapped << ""
    end
    wrapped
  end

  def wrap(paragraph)
    return [ "" ] if paragraph.empty?

    paragraph.split(/\s+/).each_with_object([]) do |word, result|
      current = result.last.to_s
      if current.empty?
        result << word
      elsif "#{current} #{word}".length <= WRAP_WIDTH
        result[-1] = "#{current} #{word}"
      else
        result << word
      end
    end
  end

  def page_stream(page_lines)
    commands = [ "BT", "/F1 11 Tf", "#{LEFT} #{TOP} Td", "#{LEADING} TL" ]
    page_lines.each do |line|
      commands << "(#{escape(line)}) Tj"
      commands << "T*"
    end
    commands << "ET"
    commands.join("\n")
  end

  def escape(text)
    text.gsub("\\", "\\\\\\").gsub("(", "\\(").gsub(")", "\\)")
  end

  def add_object(objects, body)
    objects << body
    objects.length
  end

  def build_pdf(objects, catalog_id)
    output = +"%PDF-1.4\n"
    offsets = [ 0 ]

    objects.each_with_index do |body, index|
      offsets << output.bytesize
      output << "#{index + 1} 0 obj\n#{body}\nendobj\n"
    end

    xref_offset = output.bytesize
    output << "xref\n0 #{objects.length + 1}\n"
    output << "0000000000 65535 f \n"
    offsets[1..].each { |offset| output << format("%010d 00000 n \n", offset) }
    output << "trailer\n<< /Size #{objects.length + 1} /Root #{catalog_id} 0 R >>\n"
    output << "startxref\n#{xref_offset}\n%%EOF\n"
    output
  end
end

FileUtils.mkdir_p(OUTPUT_DIR)
FileUtils.rm_f(Dir[File.join(OUTPUT_DIR, "*.pdf")])

DOCS.each do |filename, document|
  SimplePdf.write(File.join(OUTPUT_DIR, filename), document.fetch(:title), document.fetch(:body))
end

puts "Generated #{DOCS.size} HALO demo PDFs in #{OUTPUT_DIR}"
