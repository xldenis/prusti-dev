fn main() {
	let mut x = 1;
	let y = &mut x;

	*y = 2;
	// assert!(x == 1);
}