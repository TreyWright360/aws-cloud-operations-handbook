# Role Runbook: AI Solutions Architect & AI Agent Developer

**Target Job Titles:** AI Solutions Architect | AI Agent Developer | LLM & Voice AI Engineer  
**Core Responsibility:** Architecting high-availability RAG systems, managing LLM API rate limits/costs, and deploying resilient multi-channel voice/chat agents.

---

## 🚨 Scenario: LLM API Rate-Limit Throttling & RAG Knowledge Base Retrieval Lag

* **Trigger:** API Latency Alert: `AI Agent Response Time > 8,000ms` and `OpenAI/Anthropic HTTP 429 RateLimitError > 15%`.
* **Business Impact:** Live customer voice receptionists and web chatbots are dropping active customer calls and freezing.

---

## 🛠️ Step-by-Step Triage & Fallback Routing Protocol

### Phase 1: Immediate Multi-Model Fallback Activation
1. **Engage Dynamic Model Routing (Circuit Breaker):**
   * If Primary Provider (e.g. OpenAI GPT-4o) returns `429 Too Many Requests` or times out (>3s), dynamically failover to Secondary Provider (Anthropic Claude 3.5 Sonnet / AWS Bedrock Claude).
   * Code pattern:
     ```python
     try:
         response = call_primary_llm(prompt, timeout=3.0)
     except (RateLimitError, APITimeoutError):
         logger.warning("Primary LLM throttled. Switching to secondary failover model.")
         response = call_fallback_llm(prompt)
     ```
2. **Enable Semantic Response Caching (Redis / DynamoDB):**
   * Check if exact or semantically similar query was answered in last 24h before making external LLM calls.

### Phase 2: RAG Vector Database & Embedding Triage
1. **Check Vector Database Latency (Pinecone / pgvector / Qdrant):**
   * Verify embedding generation time. If embedding API is slow, fall back to cached document chunks.
2. **Token Budget & Prompt Truncation:**
   * Clamp conversation history window (sliding window of last 5 turns) to prevent exceeding context limits and incurring massive token costs.

### Phase 3: Telemetry & Quality Assurance Verification
1. **Inspect Agent Conversation Logs:**
   * Verify that fallback responses maintain strict system prompt adherence and do not hallucinate.
2. **Review API Spend:**
   * Check token consumption metrics to ensure runaway agent loops are not inflating billing.

---

## 🎤 How to Explain This Runbook in Interviews
> *"Building production AI agents requires defensive architecture. You cannot rely on a single LLM API. My runbook implements multi-model circuit breakers, semantic caching, and strict token budget sliding windows to maintain 99.9% agent uptime even during upstream provider outages."*
