import Foundation

/// Defines how dates can be selected in the calendar.
public enum CalendarSelectionMode {
    /// Only one date can be selected at a time.
    case single
    /// Multiple individual dates can be selected.
    case multiple
    /// A contiguous date range can be selected.
    case range
}
