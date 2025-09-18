enum Status {
  pending,
  approved,
  rejected,
  draft,
  active,
  inactive;

  static Status fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return Status.pending;
      case 'approved':
        return Status.approved;
      case 'rejected':
        return Status.rejected;
      case 'draft':
        return Status.draft;
      case 'active':
        return Status.active;
      case 'inactive':
        return Status.inactive;
      default:
        return Status.pending;
    }
  }

  String toJson() => name;

  static Status fromJson(String json) => Status.fromString(json);
}