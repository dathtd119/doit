//! Fixture binary that references WidgetCore (impact surface).

use sample_fixture::{format_widget, WidgetCore};

fn main() {
    let core = WidgetCore::new("fixture");
    let rendered = format_widget(&core);
    println!("{rendered}");
    touch_widget(&core);
}

fn touch_widget(core: &WidgetCore) {
    let _ = core.label();
}
