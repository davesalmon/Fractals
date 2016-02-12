/*+
 *
 *  Mandelbrot.h
 *
 *  Copyright © 2016 David C. Salmon. All Rights Reserved.
 *
 *  Compute points in the complex plane for the Mandelbrot set.
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

class Mandelbrot {
public:
	//	Construct mandelbrot set calculator.
	Mandelbrot(int maxIters, double radius, double x0, double y0);
	
	// Compute the number of iterations for the point p, q. This point is
	// used as lambda in z^2 - lambda.
	unsigned short operator () (double lambdaX, double lambdaY) const;
	
private:
	int maxiter;
	double R;
	double x0;
	double y0;
};

//----------------------------------------------------------------------------------------
//  Mandelbrot::Mandelbrot                                                    constructor
//
//      construct Mandelbrot set calculator.
//
//  int maxIters   -> the maximum iterations to allow.
//  double radius  -> the radius for divergence.
//  double x0      -> the real component of initial z value.
//  double y0      -> the imaginary component of initial z value.
//
//  returns nothing
//----------------------------------------------------------------------------------------
Mandelbrot::Mandelbrot(int maxIters, double radius, double x0, double y0)
: maxiter(maxIters)
, R(radius)
, x0(x0)
, y0(y0) {
}

//----------------------------------------------------------------------------------------
//  Mandelbrot::operator ()                                                        inline
//
//      Return the number of iterations required for divergence of the formula
//		z^2 - λ for the the specified point in the plane.
//		The given point is the real and imaginary components of λ for iteration.
//
//  double lambdaX         -> real component of λ.
//  double lambdaY         -> imaginary component of λ.
//
//  returns unsigned short <- the number of iterations for divergence.
//----------------------------------------------------------------------------------------
inline
unsigned short
Mandelbrot::operator () (double lambdaX, double lambdaY) const {
	double x = x0;
	double y = y0;
	
	for (int i = 0; i < maxiter; ++i) {
		double newx = x * x - y * y - lambdaX;
		double newy = 2 * x * y - lambdaY;
		//double s = x + y;
		if (newx * newx + newy * newy > R)
		return i;
		x = newx;
		y = newy;
	}
	
	return maxiter;
}

#if 0

// an experiment...

class Mandelbrot2 {
public:
	Mandelbrot2(int maxIters, double radius, double x0, double y0)
		: maxiter(maxIters)
		, R(radius)
		, x0(x0)
		, y0(y0) {
	}

	unsigned short operator () (double lambdaX, double lambdaY) const {
		double x = x0;
		double y = y0;
		
		for (int i = 0; i < maxiter; ++i) {
			double newx = cos(x) - lambdaX;
			double newy = sin(y) - lambdaY;
			//double s = x + y;
			if (newx * newx + newy * newy > R)
				return i;
			x = newx;
			y = newy;
		}
		
		return maxiter;
	}

private:
	int maxiter;
	double R;
	double x0;
	double y0;
};
#endif

