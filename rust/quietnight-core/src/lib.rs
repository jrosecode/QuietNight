#![forbid(unsafe_op_in_unsafe_fn)]
#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct QnResult {
    pub rms: f32,
    pub peak: f32,
    pub confidence: f32,
    pub severity: u8,
    pub periodicity: f32,
}
fn clamp(v: f32) -> f32 {
    v.clamp(0.0, 1.0)
}
pub fn analyze(samples: &[f32], baseline: f32) -> QnResult {
    if samples.is_empty() {
        return QnResult {
            rms: 0.0,
            peak: 0.0,
            confidence: 0.0,
            severity: 0,
            periodicity: 0.0,
        };
    }
    let rms = (samples.iter().map(|x| x * x).sum::<f32>() / samples.len() as f32).sqrt();
    let peak = samples.iter().fold(0.0f32, |a, x| a.max(x.abs()));
    let crossings = samples
        .windows(2)
        .filter(|w| (w[0] >= 0.0) != (w[1] >= 0.0))
        .count() as f32
        / samples.len() as f32;
    let periodicity = clamp(1.0 - (crossings - 0.08).abs() * 7.0);
    let signal = clamp((rms - baseline.max(0.005)) / (0.35 - baseline.max(0.005)));
    let confidence = clamp(signal * 0.7 + periodicity * 0.3);
    let severity = if confidence < 0.35 {
        0
    } else if rms < 0.12 {
        1
    } else if rms < 0.28 {
        2
    } else {
        3
    };
    QnResult {
        rms,
        peak,
        confidence,
        severity,
        periodicity,
    }
}
pub fn night_score(events: &[QnResult]) -> u32 {
    if events.is_empty() {
        return 0;
    }
    let weighted: f32 = events
        .iter()
        .map(|e| e.confidence * e.severity as f32)
        .sum();
    ((weighted / events.len() as f32) * 33.333)
        .round()
        .clamp(0.0, 100.0) as u32
}
/// Analyze one PCM frame through the C ABI.
///
/// # Safety
/// `samples` must be null with `len == 0`, or point to `len` valid contiguous
/// `f32` samples for the duration of this call.
#[no_mangle]
pub unsafe extern "C" fn qn_analyze(samples: *const f32, len: usize, baseline: f32) -> QnResult {
    if samples.is_null() || len == 0 {
        return analyze(&[], baseline);
    };
    let s = unsafe { std::slice::from_raw_parts(samples, len) };
    analyze(s, baseline)
}
#[no_mangle]
pub extern "C" fn qn_version() -> u32 {
    1
}
