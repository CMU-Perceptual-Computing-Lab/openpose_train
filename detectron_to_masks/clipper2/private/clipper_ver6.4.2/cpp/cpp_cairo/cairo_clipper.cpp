/*******************************************************************************
*                                                                              *
* Author    :  Angus Johnson                                                   *
* Version   :  1.1                                                             *
* Date      :  4 April 2011                                                    *
* Copyright :  Angus Johnson 2010-2011                                         *
*                                                                              *
* License:                                                                     *
* Use, modification & distribution is subject to Boost Software License Ver 1. *
* http://www.boost.org/LICENSE_1_0.txt                                         *
*                                                                              *
* Modified by Mike Owens to support coordinate transformation                  *
*******************************************************************************/

#include <stdexcept>
#include <cmath>
#include <cairo.h>
#include "clipper.hpp"
#include "cairo_clipper.hpp"

namespace ClipperLib {
  namespace cairo {

    namespace {

      inline cInt Round(double val)
      {
        if ((val < 0)) return (cInt)(val - 0.5); else return (cInt)(val + 0.5);
      }

      void transform_point(cairo_t* pen, Transform transform, cInt* x, cInt* y)
      {
        double _x = (double)*x, _y = (double)*y;
        switch (transform)
        {
          case tDeviceToUser:
            cairo_device_to_user(pen, &_x, &_y);
            break;
          case tUserToDevice:
            cairo_user_to_device(pen, &_x, &_y);
            break;
          default:
            ;
        }
        *x = Round(_x); *y = Round(_y);
      }
    }

    void cairo_to_clipper(cairo_t* cr,
                          Paths &pg,
                          int scaling_factor,
                          Transform transform)
    {
      if (scaling_factor > 8 || scaling_factor < 0)
        throw clipperCairoException("cairo_to_clipper: invalid scaling factor");
      double scaling = std::pow((double)10, scaling_factor);

      pg.clear();
      cairo_path_t *path = cairo_copy_path_flat(cr);

      int poly_count = 0;
      for (int i = 0; i < path->num_data; i += path->data[i].header.length) {
        if( path->data[i].header.type == CAIRO_PATH_CLOSE_PATH) poly_count++;
      }

      pg.resize(poly_count);
      int i = 0, pc = 0;
      while (pc < poly_count)
      {
        int vert_count = 1;
        int j = i;
        while(j < path->num_data &&
          path->data[j].header.type != CAIRO_PATH_CLOSE_PATH)
        {
          if (path->data[j].header.type == CAIRO_PATH_LINE_TO)
            vert_count++;
          j += path->data[j].header.length;
        }
        pg[pc].resize(vert_count);
        if (path->data[i].header.type != CAIRO_PATH_MOVE_TO) {
          pg.resize(pc);
          break;
        }
        pg[pc][0].X = Round(path->data[i+1].point.x *scaling);
        pg[pc][0].Y = Round(path->data[i+1].point.y *scaling);
        if (transform != tNone)
          transform_point(cr, transform, &pg[pc][0].X, &pg[pc][0].Y);

        i += path->data[i].header.length;

        j = 1;
        while (j < vert_count && i < path->num_data &&
          path->data[i].header.type == CAIRO_PATH_LINE_TO) {
          pg[pc][j].X = Round(path->data[i+1].point.x *scaling);
          pg[pc][j].Y = Round(path->data[i+1].point.y *scaling);
          if (transform != tNone)
            transform_point(cr, transform, &pg[pc][j].X, &pg[pc][j].Y);
          j++;
          i += path->data[i].header.length;
        }
        pc++;
        i += path->data[i].header.length;
      }
      cairo_path_destroy(path);
    }
    //--------------------------------------------------------------------------

    void clipper_to_cairo(const Paths &pg,
                          cairo_t* cr,
                          int scaling_factor,
                          Transform transform)
    {
      if (scaling_factor > 8 || scaling_factor < 0)
        throw clipperCairoException("clipper_to_cairo: invalid scaling factor");
      double scaling = std::pow((double)10, scaling_factor);
      for (size_t i = 0; i < pg.size(); ++i)
      {
        size_t sz = pg[i].size();
        if (sz < 3)
          continue;
        cairo_new_sub_path(cr);
        for (size_t j = 0; j < sz; ++j) {
          cInt x = pg[i][j].X, y = pg[i][j].Y;
          if (transform != tNone)
            transform_point(cr, transform, &x, &y);
          cairo_line_to(cr, (double)x / scaling, (double)y / scaling);
        }
        cairo_close_path(cr);
      }
    }
    //--------------------------------------------------------------------------

  }
}
