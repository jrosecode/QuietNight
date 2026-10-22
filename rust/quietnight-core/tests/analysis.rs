use quietnight_core::{analyze, night_score};
fn sine(n: usize, amp: f32) -> Vec<f32> {
    (0..n).map(|i| ((i as f32) * 0.5).sin() * amp).collect()
}
#[test]
fn silence_is_not_snoring() {
    let r = analyze(&vec![0.0; 1024], 0.02);
    assert_eq!(r.severity, 0);
}
#[test]
fn sustained_periodic_audio_is_flagged() {
    let r = analyze(&sine(4096, 0.5), 0.02);
    assert!(r.severity >= 2);
    assert!(r.confidence > 0.5);
}
#[test]
fn empty_input_is_safe() {
    assert_eq!(analyze(&[], 0.02).confidence, 0.0);
}
#[test]
fn score_is_bounded() {
    let r = analyze(&sine(4096, 0.8), 0.01);
    assert!(night_score(&[r, r]) <= 100);
}
#[test]
fn baseline_reduces_false_positives() {
    let s = sine(2048, 0.06);
    assert!(analyze(&s, 0.055).confidence < analyze(&s, 0.005).confidence);
}
