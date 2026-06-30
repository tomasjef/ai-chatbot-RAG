import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "history", "thread", "latest", "thinking", "heroSection", "chatSection"]
  static values = {
    storageKey: { type: String, default: "halo:messages" },
    maxMessages: { type: Number, default: 10 },
    latestQuestion: String,
    latestAnswer: String,
    latestSources: Array
  }

  connect() {
    this.messages = this.loadMessages()
    this.addLatestAnswer()
    this.render()

    this.element.addEventListener("submit", this.prepareSubmit)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.prepareSubmit)
  }

  chooseSuggestion(event) {
    this.inputTarget.value = event.currentTarget.dataset.question
    this.inputTarget.focus()
  }

  clear() {
    this.messages = []
    sessionStorage.removeItem(this.storageKeyValue)
    this.render()
    this.inputTarget.focus()
  }

  prepareSubmit = () => {
    const history = JSON.stringify(this.messages.slice(-this.maxMessagesValue))
    this.historyTargets.forEach((target) => target.value = history)
    this.thinkingTarget.hidden = false
  }

  addLatestAnswer() {
    if (!this.latestQuestionValue || !this.latestAnswerValue) return

    const signature = `${this.latestQuestionValue}\n${this.latestAnswerValue}`
    const lastPair = this.messages.slice(-2).map((message) => message.content).join("\n")
    if (lastPair === signature) {
      const lastAssistantMessage = this.messages[this.messages.length - 1]
      if (lastAssistantMessage?.role === "assistant") {
        lastAssistantMessage.sources = this.latestSourcesValue
        this.saveMessages()
      }
      return
    }

    this.messages.push({ role: "user", content: this.latestQuestionValue })
    this.messages.push({
      role: "assistant",
      content: this.latestAnswerValue,
      sources: this.latestSourcesValue
    })
    this.messages = this.messages.slice(-this.maxMessagesValue)
    this.saveMessages()
  }

  render() {
    const hasMessages = this.messages.length > 0

    this.threadTarget.replaceChildren(...this.messages.map((message) => this.messageElement(message)))
    this.threadTarget.hidden = !hasMessages

    if (this.hasLatestTarget && hasMessages) {
      this.latestTarget.hidden = true
    }

    this.heroSectionTarget.hidden = hasMessages
    this.chatSectionTarget.hidden = !hasMessages
    this.element.classList.toggle("halo-page--chatting", hasMessages)
  }

  messageElement(message) {
    const article = document.createElement("article")
    article.className = `message message--${message.role}`

    const meta = document.createElement("span")
    meta.className = "message__meta"
    meta.textContent = message.role === "user" ? "You" : "Answer"
    article.append(meta)

    const body = document.createElement("p")
    body.className = "message__body"
    body.textContent = message.content
    article.append(body)

    if (message.role === "assistant" && message.sources?.length > 0) {
      const label = document.createElement("span")
      label.className = "message__sources-label"
      label.textContent = "Sources"
      article.append(label)

      const sources = document.createElement("ul")
      sources.className = "message__sources"
      message.sources.forEach((source) => {
        const item = document.createElement("li")
        item.append(this.sourceElement(source))
        sources.append(item)
      })
      article.append(sources)
    }

    return article
  }

  sourceElement(source) {
    const title = source.title || source
    const url = source.url
    const element = url ? document.createElement("a") : document.createElement("span")
    element.className = url ? "source-button" : "source-button source-button--disabled"

    if (url) {
      element.href = url
      element.target = "_blank"
      element.rel = "noopener"
      element.setAttribute("aria-label", `Open source document: ${title}`)
    } else {
      element.setAttribute("aria-label", `Source document unavailable: ${title}`)
    }

    element.innerHTML = this.documentIcon()

    const label = document.createElement("span")
    label.className = "source-button__label"
    label.textContent = title
    element.append(label)

    return element
  }

  documentIcon() {
    return `
      <svg class="source-button__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
        <path d="M14 2v6h6"></path>
        <path d="M8 13h8"></path>
        <path d="M8 17h6"></path>
      </svg>
    `
  }

  loadMessages() {
    try {
      return JSON.parse(sessionStorage.getItem(this.storageKeyValue)) || []
    } catch {
      return []
    }
  }

  saveMessages() {
    sessionStorage.setItem(this.storageKeyValue, JSON.stringify(this.messages))
  }
}
