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

#ifndef CLIPPER_CAIRO_CLIPPER_HPP
#define CLIPPER_CAIRO_CLIPPER_HPP

#include "clipper.hpp"

typedef struct _cairo cairo_t;

namespace ClipperLib {
  namespace cairo {

    enum Transform {
      tNone,
      tUserToDevice,
      tDeviceToUser
    };

//nb: Since Clipper only accepts integer coordinates, fractional values have to
//be scaled up and down when being passed to and from Clipper. This is easily
//accomplished by setting the scaling factor (10^x) in the following functions.
//When scaling, remember that on most platforms, integer is only a 32bit value.
    void cairo_to_clipper(cairo_t* cr,
                          ClipperLib::Paths &pg,
                          int scaling_factor = 0,
                          Transform transform = tNone);

    void clipper_to_cairo(const ClipperLib::Paths &pg,
                          cairo_t* cr,
                          int scaling_factor = 0,
                          Transform transform = tNone);
  }

  class clipperCairoException : public std::exception
  {
    public:
      clipperCairoException(const char* description)
        throw(): std::exception(), m_description (description) {}
      virtual ~clipperCairoException() throw() {}
      virtual const char* what() const throw() {return m_description.c_str();}
    private:
      std::string m_description;
  };
}

#endif

