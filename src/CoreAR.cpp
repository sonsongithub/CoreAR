#include <iostream>
#include <Eigen/Dense>

using namespace Eigen;
using namespace std;

int hoge(void) {
	MatrixXd m = MatrixXd::Random(3,3);
	m = (m + MatrixXd::Constant(3,3,1.2)) * 50;
	cout << "m =" << endl << m << endl;
	VectorXd v(3);
	v << 1, 2, 3;
	cout << "m * v =" << endl << m * v << endl;
	return 1;
}