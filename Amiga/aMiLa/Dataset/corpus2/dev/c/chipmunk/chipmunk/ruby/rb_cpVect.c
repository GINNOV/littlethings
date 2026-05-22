
body {
    font-family: Verdana,Arial,Helveticassion is hereby granted, free of charge, to any person obtaining
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang=v="Content-Type" content="text/hml; charset=iso-8859-1" />
  <li="Content-Type" content="text/html; charset=iso-8859-1" />
  <meta http-equiv="Content-Script-Type" content="text/javascript" />* furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall bex-entries">
    <a href="classes/CP/Vect.html#M000032">* (CP::Veier">x</span>, <span class="ruby>identifier">y</span>); <span clth=400")
  }

  function toggleCode( id ) {
    if ( document.ge/pre>
</body>
</html>/body>
</htm = document.getElementById( id RPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR C." + id );
    else
      return false;

    elemStyle = elem.stc;
   font-size: small;
}


div#classHeader, div#fileHeader {
  yle.display = "block"
    } else {
      elemStyle.display = "no1.5em;
    margin: 0;
    margin-left: -40px;
    border-bottom:nk.h"

#include "ruby.h"
#include "rb_chipmunk.h"

ID id_body;

y;

static VALUE
rb_cpBodyAlloc(VALUE klass)
{
	cpBody *body = c)
{
	return rb_float_new(cp_bias_coef);
}

static VALUE
rb_set_cf)
{
	return rb_ivar_get(self, id_body);
}

static VALUE
rb_cpShapeSetBody(VALUE self, VALUE body)
{
	SHAPE(self)->body = BODY(b
  font-weight: bold;
}


div#bodyContent {
    padding: 0 1.5em 0 1.5em;
}

div#description {
    padding: 0.5em 1.5em;
    background: #efefef;
    border: 1px dotted #999;
}

div#descriptio      doc_dummy.rb
                </a>
        <br />
         ent;
}

div#validator-badges {
    text-align: center;
}
div#valALUE self)
{
	return VNEW(BODY(self)->v);
}

static VALUE
rb_cpBent">

    <div id="description">
      <p>
Chipmunk Game Dynamitatic VALUE
rb_cpBBGetL(VALUE self)
{
	return rb_float_new(BBGET


   </div>

    <div id="method-list">
      <h3 class="sectio *VGET(RARRAY(arr)->ptr[i]);
	
	cpFloat inertia = cpMomentForPol href="classes/CP.html#M000003">moment_for_poly (CP)</a><br />
 pBBGetT(VALUE self)
{
	return rb_float_new(BBGET(self)->t);
}

sment_for_poly</a>&nbsp;&nbsp;
      </div>
    </div>

  </div>
VALUE
rb_cpShapeGetBB(VALUE self)
{
	cpBB *bb = malloc(sizeof(cp"class-list">
      <h3 class="section-bar">Classes and Modules<}

static VALUE
rb_cpBBSetR(VALUturn val;
}

static VALUE
rb_cpBt</a><br />
Module <a href="CP/Shape.html" class="link">CP::Shap>vec2</span><span class="method-args">(x, y)</span>
          </VALUE self)
{
	return rb_float_new(SHAPE(self)->e);
}

static VALUE
rb_cpShapeGetFriction(VALUE self)
{
	return rb_float_new(SHAPE(self)->u);
}

static VALUE
rb_cpShapeSetElasticity(VALUE self, VALUE val)
{
	SHAPE(self)->e = NUM2DBL(val);
	return val;
}

static VALUE
rb_cpShapeSetFriction(VALUE self, VALUE val)
{
	SHAP_a), NUM2UINT(id_b),
								    NULL, NULL);
	} else {
		cpSpacpeGetSurfaceV(VALUE self)
{
	return VNEW(SHAPE(self)->surface_v)etL, 0);
	rb_define_method(c_cpBB, "b", rb_cpBBGetB, 0);
	rb_define_method(c_cpBB, "r", rb_cpBBGetR, 0);
	rb_define_method(c_cpBET(v)));
}

static VALUE
rb_cpBodyWorld2Local(VALUE self, VALUE v)
{
	return VNEW(cpBodyWorld2Local(BODY(self), *VGET(v)));
}

s/* --- Source code sections -------------------- */

a.source-tos(BODY(self));
	return Qnil;
}

static VALUE
rb_cpBodyApplyForce", rb_cpPinJointInit, 4);
	
	VALUE c_cpSlideJoint = rb_define_cle(*v);
	return self;
}

static VALUE
rb_cpVectPerp(VALUE self)
{Impulse(VALUE self, VALUE j, VALUE r)
{
	cpBodyApplyImpulse(BODY(self), *VGET(j), *VGET(r));
	return Qnil;
}

static VALUE
rb_cp	if(NIL_P(block)) {
		cpSpaceSetDefaultCollisionPairFunc(SPACE(suby-constant  { color: #7fffd4; background: transparent; }
.ruby(dt));
	return Qnil;
}

static VALUE
rb_cpBodyUpdatePosition(VAL04" class="method-detail">
        <a name="M000004"></a>

     

      <div id="method-M000025" class="method-detail">
        <a name="M000025"></a>

        <div class="method-heading">
   ck="popupCode('CP.src/M000004.html');return false;">
          <ame">surface_v</td>
          <td class="context-item-value">&nbtml');return false;">
          <span class="method-name">new</span><span class="method-args">(x, y)</span>
          </a>
     ><br />
    <a href="classes/CP/Vect.html#M000026">to_a (CP::Vect)</a><br />
    <a href="classes/CP/Vect.html#M000028">to_angle (CP::Vect)</a><br />
    <a hrebody, VALUE arr, VALUE offset)
{>to_s (CP::Vect)</a><br />
    <a href="classes/CP/BB.html#M0000thod(c_cpBody, "t" , rb_cpBodyGetTorque, 0);
	rb_define_method(c0002"></a>

        <div class="method-heading">
          <a hry.html#M000024">update_velocity (CP::Body)</a><br />
    <a href="classes/CP/Body.html#M000023">update_velocity (CP::Body)</a><br />
    <a href="files/doc_dummy_rb.html#M000001">vec2 (doc_dummy.rb)</a><br />
    <a href="classes/CP/Body.html#M000018">world2local (CP::Body)</a><br />
    <a href="classes/CP/BB.html#M00ine_method(c_cpBody, "w=", rb_cpBodySetAVel, 1);
	rb_define_methl>th the given mass, inner and
outer radii, and offset. <em>offset</em> should be a <a
href="CP/Vect.html">CP::Vect</a>.
</p>
  moveJoint(VALUE self, VALUE joint)
{
	cpSpaceRemoveJoint(SPACE(self), JOINT(joint));
	return rb_ary_delete(rb_iv_get(self, "joinass="method-heading">
          <a href="CP.src/M000003.html" ta;
	rb_define_method(c_cpBody, "apply_impulse", rb_cpBodyApplyImpode('CP.src/M000003.html');return false;">
          <span classers, 0);
	rb_define_method(m_cpShape, "layers=", rb_cpShapeSetLayers, 1);
	
	rb_
	rb_define_method(c_cpVect, "rotate", rb_cpVectRotate, 1);
	rb_define_method(c_cpVect, "unrotate", rb_cpVectUnRotate, 1);
	rb_define_method(c_cpVect, "near?", rb_cpVectNear, 2);
		
	rb_define_global_function("vec2", rb_vec2, 2);
}
