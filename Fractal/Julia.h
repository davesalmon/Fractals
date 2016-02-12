/*+
 *
 *  Julia.h
 *
 *  Copyright © 2016 David C. Salmon. All Rights Reserved.
 *
 *  Compute points in the complex plane for the Julia set.
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-*/

class Julia {
public:
	//	Construct julia set calculator.
	Julia(int maxIters, double radius, double lamX, double lamY);
	
	// Compute the number of iterations for the image point p, q.
	// This point is used as the start location for convergence.
	unsigned short operator () (double x, double y) const;
	
private:
	int 	maxiter;	// maximum iterations
	double 	R;			// Radius
	double 	lambdaX;	// real component for lambda
	double 	lambdaY;	// im component for lambda
};

//----------------------------------------------------------------------------------------
//  Julia::Julia                                                              constructor
//
//      construct Julia set calculator.
//
//  int maxIters   -> the maximum iterations to allow.
//  double radius  -> the radius for divergence.
//  double lamX    -> the real component of λ.
//  double lamY    -> the imaginary component of λ.
//
//  returns nothing
//----------------------------------------------------------------------------------------
Julia::Julia(int maxIters, double radius, double lamX, double lamY)
	: maxiter(maxIters)
	, R(radius)
	, lambdaX(lamX)
	, lambdaY(lamY)
{
}

//----------------------------------------------------------------------------------------
//  Julia::operator ()                                                             inline
//
//      Return the number of iterations required for divergence of the formula
//		z^2 - λ for the the specified point in the plane.
//		The given point is the initial location for iteration.
//
//  double x               -> the starting real value for z.
//  double y               -> the starting imaginaly value for z.
//
//  returns unsigned short <- the number of iterations for divergence.
//----------------------------------------------------------------------------------------
inline
unsigned short
Julia::operator () (double x, double y) const {
	
	for (int i = 0; i < maxiter; ++i) {
		double newx = x * x - y * y - lambdaX;
		double newy = 2 * x * y - lambdaY;
		if (newx * newx + newy * newy > R)
		return i;
		x = newx;
		y = newy;
	}
	
	return maxiter;
}

#if 0

// an experiment...

class Julia2 {
public:
	Julia2(int maxIters, double radius, double lamX, double lamY)
		: maxiter(maxIters)
		, R(radius)
		, lambdaX(lamX)
		, lambdaY(lamY) {
	}

	unsigned short operator () (double x, double y) const {
		for (int i = 0; i < maxiter; ++i) {
			double newx = x * x * x - 3 * x * y * y - lambdaX;
			double newy = 3 * x * x * y - y * y * y - lambdaY;
			if (newx * newx + newy * newy > R)
				return i;
			x = newx;
			y = newy;
		}
		
		return maxiter;
	}

private:
	int 	maxiter;	// maximum iterations
	double 	R;			// Radius
	double 	lambdaX;	// real component for lambda
	double 	lambdaY;	// im component for lambda
};

#endif

