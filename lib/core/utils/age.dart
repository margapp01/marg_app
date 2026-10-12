/// True when someone born on [dob] has turned [years] by [now] (calendar years;
/// a 29 February birthday counts from 1 March in non-leap years).
bool isAtLeastAge(DateTime dob, int years, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final birthday = DateTime(dob.year + years, dob.month, dob.day);
  return !birthday.isAfter(DateTime(today.year, today.month, today.day));
}
