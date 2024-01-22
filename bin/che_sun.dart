void main(List<String> args) {
  double total = 143800;
  int year = 2022;
  int month = 10;
  double scale = 0.006;
  while (year <= 2029) {
    month += 1;
    if (month == 13) {
      year += 1;
      month = 1;
    }
    total = total * (1 - scale);
    print('$year-$month $total');
  }
}
