//! Fixture library for CodeGraph explore/impact (VAL-M3-CG-001).

/// Anchor type for definition lookups.
pub struct WidgetCore {
    pub name: String,
}

impl WidgetCore {
    pub fn new(name: impl Into<String>) -> Self {
        Self { name: name.into() }
    }

    pub fn label(&self) -> &str {
        &self.name
    }
}

/// Distinct helper used only from main (definition present, limited refs).
pub fn format_widget(widget: &WidgetCore) -> String {
    format!("widget:{}", widget.label())
}
