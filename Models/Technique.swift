import Foundation

/// A single evidence-by-outcome row on a technique's detail page. Tiers and
/// strengths are illustrative placeholders — see CLAUDE.md "Evidence content"
/// for why real content comes later from an actual literature review.
struct TechniqueOutcome: Identifiable, Hashable {
    let id: String
    let name: String
    let tier: String
    /// 0...1, drives the evidence bar width.
    let strength: Double
    let detail: String
}

struct Technique: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let level: String
    let durationRange: String
    let overview: String
    let howItsPracticed: String
    let outcomes: [TechniqueOutcome]
}

extension Technique {
    /// The only technique built for this pilot — the full technique library
    /// is explicitly out of scope for this pass. See CLAUDE.md "Scope".
    static let breathAwareness = Technique(
        id: "breath-awareness",
        name: "Breath Awareness",
        category: "Attention",
        level: "Beginner",
        durationRange: "5\u{2013}20 min",
        overview: "A foundational attention practice: resting your focus on the natural sensation of breathing, and gently returning to it whenever the mind wanders. Present in some form across nearly every contemplative tradition, and one of the most widely studied meditation techniques.",
        howItsPracticed: "Sit comfortably, eyes closed or softly lowered. Bring attention to the physical sensation of breathing \u{2014} air at the nostrils, or the rise and fall of the chest. When you notice your mind has wandered, that noticing is the practice; gently return attention to the breath, without judging the wandering.",
        outcomes: [
            TechniqueOutcome(id: "stress", name: "Stress", tier: "Strong", strength: 0.88, detail: "Supported by multiple randomised controlled trials and at least one meta-analysis showing reduced physiological and self-reported stress."),
            TechniqueOutcome(id: "anxiety", name: "Anxiety", tier: "Moderate", strength: 0.58, detail: "Several RCTs show benefit; effect sizes are moderate and vary by study population."),
            TechniqueOutcome(id: "sleep", name: "Sleep", tier: "Limited", strength: 0.30, detail: "Mostly observational and small trials so far; promising but not yet well established."),
            TechniqueOutcome(id: "attention", name: "Attention", tier: "Moderate", strength: 0.62, detail: "Cognitive testing shows modest, consistent improvements in sustained attention with regular practice."),
        ]
    )
}
