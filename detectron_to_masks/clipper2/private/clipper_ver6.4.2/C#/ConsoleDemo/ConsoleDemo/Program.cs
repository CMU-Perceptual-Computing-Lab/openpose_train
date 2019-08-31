using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using ClipperLib;

namespace ClipperTest1
{
    using Path = List<IntPoint>;
    using Paths = List<List<IntPoint>>;

    class Program
    {

        //a very simple class that builds an SVG file with any number of 
        //polygons of the specified formats ...
        class SVGBuilder
        {

            public class StyleInfo
            {
                public PolyFillType pft;
                public Color brushClr;
                public Color penClr;
                public double penWidth;
                public int[] dashArray;
                public Boolean showCoords;
                public StyleInfo Clone()
                {
                    StyleInfo si = new StyleInfo();
                    si.pft = this.pft;
                    si.brushClr = this.brushClr;
                    si.dashArray = this.dashArray;
                    si.penClr = this.penClr;
                    si.penWidth = this.penWidth;
                    si.showCoords = this.showCoords;
                    return si;
                }
                public StyleInfo() 
                {
                    pft = PolyFillType.pftNonZero;
                    brushClr = Color.AntiqueWhite;
                    dashArray = null;
                    penClr = Color.Black;
                    penWidth = 0.8;
                    showCoords = false;
                }
            }

            public class PolyInfo
            {
                public Paths polygons;
                public StyleInfo si;
            }

            public StyleInfo style;
            private List<PolyInfo> PolyInfoList;
            const string svg_header = "<?xml version=\"1.0\" standalone=\"no\"?>\n" +
              "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\"\n" +
              "\"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n\n" +
              "<svg width=\"{0}px\" height=\"{1}px\" viewBox=\"0 0 {2} {3}\" " +
              "version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n\n";
            const string svg_path_format = "\"\n style=\"fill:{0};" +
                " fill-opacity:{1:f2}; fill-rule:{2}; stroke:{3};" +
                " stroke-opacity:{4:f2}; stroke-width:{5:f2};\"/>\n\n";

            public SVGBuilder()
            {
                PolyInfoList = new List<PolyInfo>();
                style = new StyleInfo();
            }

            public void AddPaths(Paths poly)
            {
                if (poly.Count == 0) return;
                PolyInfo pi = new PolyInfo();
                pi.polygons = poly;
                pi.si = style.Clone();
                PolyInfoList.Add(pi);
            }

            public Boolean SaveToFile(string filename, double scale = 1.0, int margin = 10)
            {
                if (scale == 0) scale = 1.0;
                if (margin < 0) margin = 0;
                
                //calculate the bounding rect ...
                int i = 0, j = 0;
                while (i < PolyInfoList.Count)
                {
                    j = 0;
                    while (j < PolyInfoList[i].polygons.Count && 
                        PolyInfoList[i].polygons[j].Count == 0) j++;
                    if (j < PolyInfoList[i].polygons.Count) break;
                    i++;
                }
                if (i == PolyInfoList.Count) return false;
                IntRect rec = new IntRect();
                rec.left = PolyInfoList[i].polygons[j][0].X;
                rec.right = rec.left;
                rec.top = PolyInfoList[0].polygons[j][0].Y;
                rec.bottom = rec.top;

                for ( ; i < PolyInfoList.Count; i++ )
                {
                    foreach (Path pg in PolyInfoList[i].polygons)
                        foreach (IntPoint pt in pg)
                        {
                            if (pt.X < rec.left) rec.left = pt.X;
                            else if (pt.X > rec.right) rec.right = pt.X;
                            if (pt.Y < rec.top) rec.top = pt.Y;
                            else if (pt.Y > rec.bottom) rec.bottom = pt.Y;
                        }
                }

                rec.left = (Int64)((double)rec.left * scale);
                rec.top = (Int64)((double)rec.top * scale);
                rec.right = (Int64)((double)rec.right * scale);
                rec.bottom = (Int64)((double)rec.bottom * scale);
                Int64 offsetX = -rec.left + margin;
                Int64 offsetY = -rec.top + margin;

                StreamWriter writer = new StreamWriter(filename);
                if (writer == null) return false;
                writer.Write(svg_header,
                    (rec.right - rec.left) + margin * 2,
                    (rec.bottom - rec.top) + margin * 2,
                    (rec.right - rec.left) + margin * 2,
                    (rec.bottom - rec.top) + margin * 2);

                foreach (PolyInfo pi in PolyInfoList)
                {
                    writer.Write(" <path d=\"");
                    foreach (Path p in pi.polygons)
                    {
                        if (p.Count < 3) continue;
                        writer.Write(String.Format(NumberFormatInfo.InvariantInfo, " M {0:f2} {1:f2}",
                            (double)((double)p[0].X * scale + offsetX),
                            (double)((double)p[0].Y * scale + offsetY)));
                        for (int k = 1; k < p.Count; k++)
                        {
                            writer.Write(String.Format(NumberFormatInfo.InvariantInfo, " L {0:f2} {1:f2}",
                            (double)((double)p[k].X * scale + offsetX),
                            (double)((double)p[k].Y * scale + offsetY)));
                        }
                        writer.Write(" z");
                    }

                    writer.Write(String.Format(NumberFormatInfo.InvariantInfo, svg_path_format,
                    ColorTranslator.ToHtml(pi.si.brushClr),
                    (float)pi.si.brushClr.A /255,
                    (pi.si.pft == PolyFillType.pftEvenOdd ? "evenodd" : "nonzero"),
                    ColorTranslator.ToHtml(pi.si.penClr),
                    (float)pi.si.penClr.A / 255,
                    pi.si.penWidth));

                    if (pi.si.showCoords)
                    {
                        writer.Write("<g font-family=\"Verdana\" font-size=\"11\" fill=\"black\">\n\n");
                        foreach (Path p in pi.polygons)
                        {
                            foreach (IntPoint pt in p)
                            {
                                Int64 x = pt.X;
                                Int64 y = pt.Y;
                                writer.Write(String.Format(
                                    "<text x=\"{0}\" y=\"{1}\">{2},{3}</text>\n",
                                    (int)(x * scale + offsetX), (int)(y * scale + offsetY), x, y));

                            }
                            writer.Write("\n");
                        }
                        writer.Write("</g>\n");
                    }
                }
                writer.Write("</svg>\n");
                writer.Close();
                return true;
            }
        }

        ////////////////////////////////////////////////

        static bool LoadFromFile(string filename, Paths ppg, int dec_places, int xOffset = 0, int yOffset = 0)
        {
            double scaling;
            scaling = Math.Pow(10, dec_places);

            ppg.Clear();
            if (!File.Exists(filename)) return false;
            StreamReader sr = new StreamReader(filename);
            if (sr == null) return false;
            string line;
            if ((line = sr.ReadLine()) == null) return false;
            int polyCnt, vertCnt;
            if (!Int32.TryParse(line, out polyCnt) || polyCnt < 0) return false;
            ppg.Capacity = polyCnt;
            for (int i = 0; i < polyCnt; i++)
            {
                if ((line = sr.ReadLine()) == null) return false;
                if (!Int32.TryParse(line, out vertCnt) || vertCnt < 0) return false;
                Path pg = new Path(vertCnt);
                ppg.Add(pg);
                if (scaling > 0.999 & scaling < 1.001)
                    for (int j = 0; j < vertCnt; j++)
                    {
                        Int64 x, y;
                        if ((line = sr.ReadLine()) == null) return false;
                        char[] delimiters = new char[] { ',', ' ' };
                        string[] vals = line.Split(delimiters);
                        if (vals.Length < 2) return false;
                        if (!Int64.TryParse(vals[0], out x)) return false;
                        if (!Int64.TryParse(vals[1], out y))
                            if (vals.Length < 2 || !Int64.TryParse(vals[2], out y)) return false;
                        x = x + xOffset;
                        y = y + yOffset;
                        pg.Add(new IntPoint(x, y));
                    }
                else
                    for (int j = 0; j < vertCnt; j++)
                    {
                        double x, y;
                        if ((line = sr.ReadLine()) == null) return false;
                        char[] delimiters = new char[] { ',', ' ' };
                        string[] vals = line.Split(delimiters);
                        if (vals.Length < 2) return false;
                        if (!double.TryParse(vals[0], out x)) return false;
                        if (!double.TryParse(vals[1], out y))
                            if (vals.Length < 2 || !double.TryParse(vals[2], out y)) return false;
                        x = x * scaling + xOffset;
                        y = y * scaling + yOffset;
                        pg.Add(new IntPoint((Int64)Math.Round(x), (Int64)Math.Round(y)));
                    }
            }
            return true;
        }

        ////////////////////////////////////////////////
        static void SaveToFile(string filename, Paths ppg, int dec_places)
        {
            double scaling = Math.Pow(10, dec_places);
            StreamWriter writer = new StreamWriter(filename);
            if (writer == null) return;
            writer.Write("{0}\r\n", ppg.Count);
            foreach (Path pg in ppg)
            {
                writer.Write("{0}\r\n", pg.Count);
                foreach (IntPoint ip in pg)
                    writer.Write("{0:0.####}, {1:0.####}\r\n", (double)ip.X / scaling, (double)ip.Y / scaling);
            }
            writer.Close();
        }

        ////////////////////////////////////////////////

        static void OutputFileFormat()
        {
            Console.WriteLine("The expected (text) file format is ...");
            Console.WriteLine("Polygon Count");
            Console.WriteLine("First polygon vertex count");
            Console.WriteLine("first X, Y coordinate of first polygon");
            Console.WriteLine("second X, Y coordinate of first polygon");
            Console.WriteLine("etc.");
            Console.WriteLine("Second polygon vertex count (if there is one)");
            Console.WriteLine("first X, Y coordinate of second polygon");
            Console.WriteLine("second X, Y coordinate of second polygon");
            Console.WriteLine("etc.");
        }

        ////////////////////////////////////////////////

        static Path IntsToPolygon(int[] ints)
        {
            int len1 = ints.Length /2;
            Path result = new Path(len1);
            for (int i = 0; i < len1; i++)
              result.Add(new IntPoint(ints[i * 2], ints[i * 2 +1]));
            return result;
        }

        ////////////////////////////////////////////////

        static Path MakeRandomPolygon(Random r,  int maxWidth, int maxHeight, int edgeCount, Int64 scale = 1)
        {
            Path result = new Path(edgeCount);
            for (int i = 0; i < edgeCount; i++)
            {
                result.Add(new IntPoint(r.Next(maxWidth)*scale, r.Next(maxHeight)*scale));
            }
            return result;
        }
        ////////////////////////////////////////////////
        
        static void Main(string[] args)
        {
          ////quick test with random polygons ...
          //Paths ss = new Paths(1), cc = new Paths(1), sss = new Paths();
          //Random r = new Random((int)DateTime.Now.Ticks);
          //int scale = 1000000000; //tests 128bit math
          //ss.Add(MakeRandomPolygon(r, 400, 350, 9, scale));
          //cc.Add(MakeRandomPolygon(r, 400, 350, 9, scale));
          //Clipper cpr = new Clipper();
          //cpr.AddPaths(ss, PolyType.ptSubject, true);
          //cpr.AddPaths(cc, PolyType.ptClip, true);
          //cpr.Execute(ClipType.ctUnion, sss, PolyFillType.pftNonZero, PolyFillType.pftNonZero);
          //sss = Clipper.OffsetPolygons(sss, -5.0 * scale, JoinType.jtMiter, 4);
          //SVGBuilder svg1 = new SVGBuilder();
          //svg1.style.brushClr = Color.FromArgb(0x20, 0, 0, 0x9c);
          //svg1.style.penClr = Color.FromArgb(0xd3, 0xd3, 0xda);
          //svg1.AddPaths(ss);
          //svg1.style.brushClr = Color.FromArgb(0x20, 0x9c, 0, 0);
          //svg1.style.penClr = Color.FromArgb(0xff, 0xa0, 0x7a);
          //svg1.AddPaths(cc);
          //svg1.style.brushClr = Color.FromArgb(0xAA, 0x80, 0xff, 0x9c);
          //svg1.style.penClr = Color.FromArgb(0, 0x33, 0);
          //svg1.AddPaths(sss);
          //svg1.SaveToFile("solution.svg", 1.0 / scale);
          //return;

          if (args.Length < 5)
            {
                string appname = System.Environment.GetCommandLineArgs()[0];
                appname = System.IO.Path.GetFileName(appname);
                Console.WriteLine("");
                Console.WriteLine("Usage:");
                Console.WriteLine("  {0} CLIPTYPE s_file c_file INPUT_DEC_PLACES SVG_SCALE [S_FILL, C_FILL]", appname);
                Console.WriteLine("  where ...");
                Console.WriteLine("  CLIPTYPE = INTERSECTION|UNION|DIFFERENCE|XOR");
                Console.WriteLine("  FILLMODE = NONZERO|EVENODD");
                Console.WriteLine("  INPUT_DEC_PLACES = signific. decimal places for subject & clip coords.");
                Console.WriteLine("  SVG_SCALE = scale of SVG image as power of 10. (Fractions are accepted.)");
                Console.WriteLine("  both S_FILL and C_FILL are optional. The default is EVENODD.");
                Console.WriteLine("Example:");
                Console.WriteLine("  Intersect polygons, rnd to 4 dec places, SVG is 1/100 normal size ...");
                Console.WriteLine("  {0} INTERSECTION subj.txt clip.txt 0 0 NONZERO NONZERO", appname);
                return;
            }

            ClipType ct;
            switch (args[0].ToUpper())
            {
                case "INTERSECTION": ct = ClipType.ctIntersection; break;
                case "UNION": ct = ClipType.ctUnion; break;
                case "DIFFERENCE": ct = ClipType.ctDifference; break;
                case "XOR": ct = ClipType.ctXor; break;
                default: Console.WriteLine("Error: invalid operation - {0}", args[0]); return;
            }

            string subjFilename = args[1];
            string clipFilename = args[2];
            if (!File.Exists(subjFilename))
            {
                Console.WriteLine("Error: file - {0} - does not exist.", subjFilename);
                return;
            }
            if (!File.Exists(clipFilename))
            {
                Console.WriteLine("Error: file - {0} - does not exist.", clipFilename);
                return;
            }

            int decimal_places = 0;
            if (!Int32.TryParse(args[3], out decimal_places))
            {
                Console.WriteLine("Error: invalid number of decimal places - {0}", args[3]);
                return;
            }
            if (decimal_places > 8) decimal_places = 8;
            else if (decimal_places < 0) decimal_places = 0;

            double svg_scale = 0;
            if (!double.TryParse(args[4], out svg_scale))
            {
                Console.WriteLine("Error: invalid value for SVG_SCALE - {0}", args[4]);
                return;
            }
            if (svg_scale < -18) svg_scale = -18;
            else if (svg_scale > 18) svg_scale = 18;
            svg_scale = Math.Pow(10, svg_scale - decimal_places);//nb: also compensate for decimal places


            PolyFillType pftSubj = PolyFillType.pftEvenOdd;
            PolyFillType pftClip = PolyFillType.pftEvenOdd;
            if (args.Length > 6)
            {
                switch (args[5].ToUpper())
                {
                    case "EVENODD": pftSubj = PolyFillType.pftEvenOdd; break;
                    case "NONZERO": pftSubj = PolyFillType.pftNonZero; break;
                    default: Console.WriteLine("Error: invalid cliptype - {0}", args[5]); return;
                }
                switch (args[6].ToUpper())
                {
                    case "EVENODD": pftClip = PolyFillType.pftEvenOdd; break;
                    case "NONZERO": pftClip = PolyFillType.pftNonZero; break;
                    default: Console.WriteLine("Error: invalid cliptype - {0}", args[6]); return;
                }
            }

            Paths subjs = new Paths();
            Paths clips = new Paths();
            if (!LoadFromFile(subjFilename, subjs, decimal_places))
            {
                Console.WriteLine("Error processing subject polygons file - {0} ", subjFilename);
                OutputFileFormat();
                return;
            }
            if (!LoadFromFile(clipFilename, clips, decimal_places))
            {
                Console.WriteLine("Error processing clip polygons file - {0} ", clipFilename);
                OutputFileFormat();
                return;
            }

            Console.WriteLine("wait ...");
            Clipper cp = new Clipper();
            cp.AddPaths(subjs, PolyType.ptSubject, true);
            cp.AddPaths(clips, PolyType.ptClip, true);

            Paths solution = new Paths();
            //Paths solution = new Paths();
            if (cp.Execute(ct, solution, pftSubj, pftClip))
            {
                SaveToFile("solution.txt", solution, decimal_places);

                //solution = Clipper.OffsetPolygons(solution, -4, JoinType.jtRound);

                SVGBuilder svg = new SVGBuilder();
                svg.style.brushClr = Color.FromArgb(0x20, 0, 0, 0x9c);
                svg.style.penClr = Color.FromArgb(0xd3, 0xd3, 0xda);
                svg.AddPaths(subjs);
                svg.style.brushClr = Color.FromArgb(0x20, 0x9c, 0, 0);
                svg.style.penClr = Color.FromArgb(0xff, 0xa0, 0x7a);
                svg.AddPaths(clips);
                svg.style.brushClr = Color.FromArgb(0xAA, 0x80, 0xff, 0x9c);
                svg.style.penClr = Color.FromArgb(0, 0x33, 0);
                svg.AddPaths(solution);
                svg.SaveToFile("solution.svg", svg_scale);

                Console.WriteLine("finished!");
            }
            else
            {
                Console.WriteLine("failed!");
            }
        }

    } //class Program
}
