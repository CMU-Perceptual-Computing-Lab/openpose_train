namespace WindowsFormsApplication1
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.panel1 = new System.Windows.Forms.Panel();
            this.bSave = new System.Windows.Forms.Button();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.rbNone = new System.Windows.Forms.RadioButton();
            this.rbXor = new System.Windows.Forms.RadioButton();
            this.rbDifference = new System.Windows.Forms.RadioButton();
            this.rbUnion = new System.Windows.Forms.RadioButton();
            this.rbIntersect = new System.Windows.Forms.RadioButton();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.rbTest2 = new System.Windows.Forms.RadioButton();
            this.rbTest1 = new System.Windows.Forms.RadioButton();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.nudOffset = new System.Windows.Forms.NumericUpDown();
            this.lblCount = new System.Windows.Forms.Label();
            this.nudCount = new System.Windows.Forms.NumericUpDown();
            this.rbNonZero = new System.Windows.Forms.RadioButton();
            this.rbEvenOdd = new System.Windows.Forms.RadioButton();
            this.bRefresh = new System.Windows.Forms.Button();
            this.bCancel = new System.Windows.Forms.Button();
            this.panel2 = new System.Windows.Forms.Panel();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.statusStrip1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudOffset)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudCount)).BeginInit();
            this.panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // statusStrip1
            // 
            this.statusStrip1.GripStyle = System.Windows.Forms.ToolStripGripStyle.Visible;
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1});
            this.statusStrip1.Location = new System.Drawing.Point(0, 459);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(716, 22);
            this.statusStrip1.TabIndex = 4;
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Text;
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(0, 17);
            // 
            // panel1
            // 
            this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panel1.Controls.Add(this.bSave);
            this.panel1.Controls.Add(this.groupBox3);
            this.panel1.Controls.Add(this.groupBox2);
            this.panel1.Controls.Add(this.groupBox1);
            this.panel1.Controls.Add(this.bRefresh);
            this.panel1.Controls.Add(this.bCancel);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(121, 459);
            this.panel1.TabIndex = 5;
            // 
            // bSave
            // 
            this.bSave.Location = new System.Drawing.Point(9, 412);
            this.bSave.Name = "bSave";
            this.bSave.Size = new System.Drawing.Size(100, 25);
            this.bSave.TabIndex = 9;
            this.bSave.Text = "S&ave as SVG File";
            this.bSave.UseVisualStyleBackColor = true;
            this.bSave.Click += new System.EventHandler(this.bSave_Click);
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.rbNone);
            this.groupBox3.Controls.Add(this.rbXor);
            this.groupBox3.Controls.Add(this.rbDifference);
            this.groupBox3.Controls.Add(this.rbUnion);
            this.groupBox3.Controls.Add(this.rbIntersect);
            this.groupBox3.Location = new System.Drawing.Point(9, 12);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(100, 125);
            this.groupBox3.TabIndex = 5;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "&Boolean Op:";
            // 
            // rbNone
            // 
            this.rbNone.AutoSize = true;
            this.rbNone.Location = new System.Drawing.Point(14, 100);
            this.rbNone.Name = "rbNone";
            this.rbNone.Size = new System.Drawing.Size(51, 17);
            this.rbNone.TabIndex = 4;
            this.rbNone.Text = "None";
            this.rbNone.UseVisualStyleBackColor = true;
            this.rbNone.CheckedChanged += new System.EventHandler(this.rbNonZero_Click);
            // 
            // rbXor
            // 
            this.rbXor.AutoSize = true;
            this.rbXor.Location = new System.Drawing.Point(14, 81);
            this.rbXor.Name = "rbXor";
            this.rbXor.Size = new System.Drawing.Size(48, 17);
            this.rbXor.TabIndex = 3;
            this.rbXor.Text = "XOR";
            this.rbXor.UseVisualStyleBackColor = true;
            this.rbXor.CheckedChanged += new System.EventHandler(this.rbNonZero_Click);
            // 
            // rbDifference
            // 
            this.rbDifference.AutoSize = true;
            this.rbDifference.Location = new System.Drawing.Point(14, 60);
            this.rbDifference.Name = "rbDifference";
            this.rbDifference.Size = new System.Drawing.Size(74, 17);
            this.rbDifference.TabIndex = 2;
            this.rbDifference.Text = "Difference";
            this.rbDifference.UseVisualStyleBackColor = true;
            this.rbDifference.CheckedChanged += new System.EventHandler(this.rbNonZero_Click);
            // 
            // rbUnion
            // 
            this.rbUnion.AutoSize = true;
            this.rbUnion.Location = new System.Drawing.Point(14, 39);
            this.rbUnion.Name = "rbUnion";
            this.rbUnion.Size = new System.Drawing.Size(53, 17);
            this.rbUnion.TabIndex = 1;
            this.rbUnion.Text = "Union";
            this.rbUnion.UseVisualStyleBackColor = true;
            this.rbUnion.CheckedChanged += new System.EventHandler(this.rbNonZero_Click);
            // 
            // rbIntersect
            // 
            this.rbIntersect.AutoSize = true;
            this.rbIntersect.Checked = true;
            this.rbIntersect.Location = new System.Drawing.Point(14, 19);
            this.rbIntersect.Name = "rbIntersect";
            this.rbIntersect.Size = new System.Drawing.Size(66, 17);
            this.rbIntersect.TabIndex = 0;
            this.rbIntersect.TabStop = true;
            this.rbIntersect.Text = "Intersect";
            this.rbIntersect.UseVisualStyleBackColor = true;
            this.rbIntersect.CheckedChanged += new System.EventHandler(this.rbNonZero_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.rbTest2);
            this.groupBox2.Controls.Add(this.rbTest1);
            this.groupBox2.Location = new System.Drawing.Point(9, 310);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(100, 61);
            this.groupBox2.TabIndex = 7;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Sample";
            // 
            // rbTest2
            // 
            this.rbTest2.AutoSize = true;
            this.rbTest2.Location = new System.Drawing.Point(14, 35);
            this.rbTest2.Name = "rbTest2";
            this.rbTest2.Size = new System.Drawing.Size(46, 17);
            this.rbTest2.TabIndex = 1;
            this.rbTest2.Text = "&Two";
            this.rbTest2.UseVisualStyleBackColor = true;
            this.rbTest2.Click += new System.EventHandler(this.rbTest1_Click);
            // 
            // rbTest1
            // 
            this.rbTest1.AutoSize = true;
            this.rbTest1.Checked = true;
            this.rbTest1.Location = new System.Drawing.Point(14, 17);
            this.rbTest1.Name = "rbTest1";
            this.rbTest1.Size = new System.Drawing.Size(45, 17);
            this.rbTest1.TabIndex = 0;
            this.rbTest1.TabStop = true;
            this.rbTest1.Text = "&One";
            this.rbTest1.UseVisualStyleBackColor = true;
            this.rbTest1.Click += new System.EventHandler(this.rbTest1_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.nudOffset);
            this.groupBox1.Controls.Add(this.lblCount);
            this.groupBox1.Controls.Add(this.nudCount);
            this.groupBox1.Controls.Add(this.rbNonZero);
            this.groupBox1.Controls.Add(this.rbEvenOdd);
            this.groupBox1.Location = new System.Drawing.Point(9, 144);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(100, 159);
            this.groupBox1.TabIndex = 6;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Options:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(11, 108);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(38, 13);
            this.label2.TabIndex = 4;
            this.label2.Text = "O&ffset:";
            // 
            // nudOffset
            // 
            this.nudOffset.DecimalPlaces = 1;
            this.nudOffset.Location = new System.Drawing.Point(14, 126);
            this.nudOffset.Maximum = new decimal(new int[] {
            10,
            0,
            0,
            0});
            this.nudOffset.Minimum = new decimal(new int[] {
            10,
            0,
            0,
            -2147483648});
            this.nudOffset.Name = "nudOffset";
            this.nudOffset.Size = new System.Drawing.Size(54, 20);
            this.nudOffset.TabIndex = 5;
            this.nudOffset.ValueChanged += new System.EventHandler(this.nudCount_ValueChanged);
            // 
            // lblCount
            // 
            this.lblCount.AutoSize = true;
            this.lblCount.Location = new System.Drawing.Point(11, 62);
            this.lblCount.Name = "lblCount";
            this.lblCount.Size = new System.Drawing.Size(71, 13);
            this.lblCount.TabIndex = 2;
            this.lblCount.Text = "Vertex &Count:";
            // 
            // nudCount
            // 
            this.nudCount.Location = new System.Drawing.Point(14, 80);
            this.nudCount.Minimum = new decimal(new int[] {
            3,
            0,
            0,
            0});
            this.nudCount.Name = "nudCount";
            this.nudCount.Size = new System.Drawing.Size(54, 20);
            this.nudCount.TabIndex = 3;
            this.nudCount.Value = new decimal(new int[] {
            50,
            0,
            0,
            0});
            this.nudCount.ValueChanged += new System.EventHandler(this.bRefresh_Click);
            // 
            // rbNonZero
            // 
            this.rbNonZero.AutoSize = true;
            this.rbNonZero.Checked = true;
            this.rbNonZero.Location = new System.Drawing.Point(14, 39);
            this.rbNonZero.Name = "rbNonZero";
            this.rbNonZero.Size = new System.Drawing.Size(67, 17);
            this.rbNonZero.TabIndex = 1;
            this.rbNonZero.TabStop = true;
            this.rbNonZero.Text = "Non&Zero";
            this.rbNonZero.UseVisualStyleBackColor = true;
            this.rbNonZero.Click += new System.EventHandler(this.rbNonZero_Click);
            // 
            // rbEvenOdd
            // 
            this.rbEvenOdd.AutoSize = true;
            this.rbEvenOdd.Location = new System.Drawing.Point(14, 21);
            this.rbEvenOdd.Name = "rbEvenOdd";
            this.rbEvenOdd.Size = new System.Drawing.Size(70, 17);
            this.rbEvenOdd.TabIndex = 0;
            this.rbEvenOdd.Text = "&EvenOdd";
            this.rbEvenOdd.UseVisualStyleBackColor = true;
            this.rbEvenOdd.Click += new System.EventHandler(this.rbNonZero_Click);
            // 
            // bRefresh
            // 
            this.bRefresh.Location = new System.Drawing.Point(9, 381);
            this.bRefresh.Name = "bRefresh";
            this.bRefresh.Size = new System.Drawing.Size(100, 25);
            this.bRefresh.TabIndex = 8;
            this.bRefresh.Text = "&New Sample";
            this.bRefresh.UseVisualStyleBackColor = true;
            this.bRefresh.Click += new System.EventHandler(this.bRefresh_Click);
            // 
            // bCancel
            // 
            this.bCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.bCancel.Location = new System.Drawing.Point(9, 458);
            this.bCancel.Name = "bCancel";
            this.bCancel.Size = new System.Drawing.Size(100, 27);
            this.bCancel.TabIndex = 11;
            this.bCancel.Text = "E&xit";
            this.bCancel.UseVisualStyleBackColor = true;
            this.bCancel.Click += new System.EventHandler(this.bClose_Click);
            // 
            // panel2
            // 
            this.panel2.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panel2.Controls.Add(this.pictureBox1);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel2.Location = new System.Drawing.Point(121, 0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(595, 459);
            this.panel2.TabIndex = 6;
            // 
            // pictureBox1
            // 
            this.pictureBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pictureBox1.Location = new System.Drawing.Point(0, 0);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(591, 455);
            this.pictureBox1.TabIndex = 1;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.DoubleClick += new System.EventHandler(this.bRefresh_Click);
            // 
            // saveFileDialog1
            // 
            this.saveFileDialog1.DefaultExt = "svg";
            this.saveFileDialog1.Filter = "SVG Files (*.svg)|*.svg";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(716, 481);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.statusStrip1);
            this.DoubleBuffered = true;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.KeyPreview = true;
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Clipper C# Demo1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.Form1_KeyDown);
            this.Resize += new System.EventHandler(this.Form1_Resize);
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudOffset)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.nudCount)).EndInit();
            this.panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.RadioButton rbNone;
        private System.Windows.Forms.RadioButton rbXor;
        private System.Windows.Forms.RadioButton rbDifference;
        private System.Windows.Forms.RadioButton rbUnion;
        private System.Windows.Forms.RadioButton rbIntersect;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.RadioButton rbTest2;
        private System.Windows.Forms.RadioButton rbTest1;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.NumericUpDown nudOffset;
        private System.Windows.Forms.Label lblCount;
        private System.Windows.Forms.NumericUpDown nudCount;
        private System.Windows.Forms.RadioButton rbNonZero;
        private System.Windows.Forms.RadioButton rbEvenOdd;
        private System.Windows.Forms.Button bRefresh;
        private System.Windows.Forms.Button bCancel;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button bSave;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
    }
}

