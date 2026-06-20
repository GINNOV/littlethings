#ifndef EVERSION__MATH_H
#define EVERSION__MATH_H

////////////////////////////////////////////////////////////////////////////////

namespace eversion {

// CLASSES /////////////////////////////////////////////////////////////////////
// basic math types

template<typename T>
struct point2D
{
	T x,y;

	// ctor
	point2D() { set(0,0); }
	point2D(T _x, T _y) { set(_x,_y); }
	// cctor
	template<typename U> point2D(const point2D<U>& p) { *this = p; }

	// operators
	template<typename U> const point2D& operator=(const point2D<U>& p) { x=(T)p.x; y=(T)p.y; return *this; }
	bool operator==(const point2D& p) const { return (x == p.x && y == p.y); }

	const point2D& operator+=(const point2D& p) { x+=p.x; y+=p.y; return *this; }
	const point2D& operator-=(const point2D& p) { x-=p.x; y-=p.y; return *this; }
	const point2D& operator*=(const point2D& p) { x*=p.x; y*=p.y; return *this; }
	const point2D& operator/=(const point2D& p) { x/=p.x; y/=p.y; return *this; }

	template<typename U> point2D& operator*=(U f) { x*=f; y*=f; return *this; }
	template<typename U> point2D& operator/=(U f) { x/=f; y/=f; return *this; }

	point2D operator+(const point2D& p) const { point2D pr(x+p.x, y+p.y); return pr; }
	point2D operator-(const point2D& p) const { point2D pr(x-p.x, y-p.y); return pr; }
	point2D operator*(const point2D& p) const { point2D pr(x*p.x, y*p.y); return pr; }
	point2D operator/(const point2D& p) const { point2D pr(x/p.x, y/p.y); return pr; }

	template<typename U> point2D operator*(U f) { point2D pr(x*f, y*f); return pr; }
	template<typename U> point2D operator/(U f) { point2D pr(x/f, y/f); return pr; }

	template<typename U> const point2D& operator<<=(const U f) { x<<f; y<<f; return *this; }
	template<typename U> const point2D& operator>>=(const U f) { x>>f; y>>f; return *this; }
	template<typename U> point2D operator<<(U f) const { point2D pr(x<<f, y<<f); return pr; }
	template<typename U> point2D operator>>(U f) const { point2D pr(x>>f, y>>f); return pr; }

	// functions
	void set(T _x, T _y) { x=_x; y=_y; }
};

// assumings: x2>=x1, y2>=y1
template<typename T>
struct rect
{
	T x1,x2,y1,y2;

	// ctor
	rect() { set(0,0,0,0); }
	rect(T _x1, T _y1, T _x2, T _y2) { set(_x1,_y1,_x2,_y2); }
	template<typename U> rect(const point2D<U> &y1_x1, const point2D<U> &y2_x2) { set(y1_x1,y2_x2); }
	template<typename U> rect(const point2D<U>& p,T width,T height) { set(p,width,height); }
	// cctor
	template<typename U> rect(const rect<U>& rc) { *this = rc; }

	// operators
	template<typename U> const rect& operator=(const rect<U>& rc)
	{ x1=(T)rc.x1; x2=(T)rc.x2; y1=(T)rc.y1; y2=(T)rc.y2; return *this; }
	template<typename U> const rect& operator=(const point2D<U>& p)
	{ x2=(T)p.x+x2-x1; x1=(T)p.x; y2=(T)p.y+y2-y1; y1=(T)p.y; return *this; }

	template<typename U> const rect& operator+=(const rect<U>& rc)
	{ x1+=(T)rc.x1; x2+=(T)rc.x2; y1+=(T)rc.y1; y2+=(T)rc.y2; return *this; }
	template<typename U> const rect& operator+=(const point2D<U>& p)
	{ x1+=(T)p.x; x2+=(T)p.x; y1+=(T)p.y; y2+=(T)p.y; return *this; }

	bool operator==(const rect &rc) const
	{ return (x1==rc.x1 && y1==rc.y1 && x2==rc.x2 && y2==rc.y2); }

	// functions
	void set(T _x1, T _y1, T _x2, T _y2) { x1 = _x1; x2 = _x2; y1 = _y1; y2 = _y2; }
	template<typename U> void set(const point2D<U> &y1_x1, const point2D<U> &y2_x2)
	{ x1 = (T)y1_x1.x; x2 = (T)y2_x2.x; y1 = (T)y1_x1.y; y2 = (T)y2_x2.y; }
	template<typename U> void set(const point2D<U>& p,T width,T height)
	{ x1 = (T)p.x; x2 = (T)p.x+width; y1 = (T)p.y; y2 = (T)p.y+height; }
	template<typename U> void set(const point2D<U> &p)
	{ T w=x2-x1; T h=y2-y1; x1=(T)p.x; y1=(T)p.y; x2=x1+w; y2=y1+h; }

	template<typename U> bool isinside(const point2D<U>& p)
	{ return (T)p.x<=x2 && (T)p.x>=x1 && (T)p.y<=y2 && (T)p.y>=y1; }
};

////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////

#endif //EVERSION__MATH_H
