namespace BestEditor
{
    partial class Main
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Main));
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.文件FToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.新建NToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.打开OToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.保存SToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.另存为AToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.页面设置UToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.打印PToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem1 = new System.Windows.Forms.ToolStripSeparator();
            this.退出XToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.编辑EToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.撤消UToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator3 = new System.Windows.Forms.ToolStripSeparator();
            this.剪切TToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.复制CToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.粘贴PToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.删除LToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem2 = new System.Windows.Forms.ToolStripSeparator();
            this.查找FToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.查找下一个NToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.替换RToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.转到GToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItem3 = new System.Windows.Forms.ToolStripSeparator();
            this.全选AToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.时间日期DToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.格式OToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.自动换行WToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.字体FToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.查看VToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.状态栏SToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.帮助HToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.查看帮助HToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.关于记事本AToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.richTextBoxBoard = new System.Windows.Forms.RichTextBox();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.pageSetupDialog1 = new System.Windows.Forms.PageSetupDialog();
            this.printDocument1 = new System.Drawing.Printing.PrintDocument();
            this.printDialog1 = new System.Windows.Forms.PrintDialog();
            this.fontDialog1 = new System.Windows.Forms.FontDialog();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabel2 = new System.Windows.Forms.ToolStripStatusLabel();
            this.menuStrip1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.文件FToolStripMenuItem,
            this.编辑EToolStripMenuItem,
            this.格式OToolStripMenuItem,
            this.查看VToolStripMenuItem,
            this.帮助HToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(566, 25);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // 文件FToolStripMenuItem
            // 
            this.文件FToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.新建NToolStripMenuItem,
            this.打开OToolStripMenuItem,
            this.保存SToolStripMenuItem,
            this.另存为AToolStripMenuItem,
            this.toolStripSeparator1,
            this.页面设置UToolStripMenuItem,
            this.打印PToolStripMenuItem,
            this.toolStripMenuItem1,
            this.退出XToolStripMenuItem});
            this.文件FToolStripMenuItem.Name = "文件FToolStripMenuItem";
            this.文件FToolStripMenuItem.Size = new System.Drawing.Size(58, 21);
            this.文件FToolStripMenuItem.Text = "文件(F)";
            // 
            // 新建NToolStripMenuItem
            // 
            this.新建NToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.新建NToolStripMenuItem.Name = "新建NToolStripMenuItem";
            this.新建NToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)));
            this.新建NToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.新建NToolStripMenuItem.Text = "新建(N)";
            this.新建NToolStripMenuItem.Click += new System.EventHandler(this.新建NToolStripMenuItem_Click);
            // 
            // 打开OToolStripMenuItem
            // 
            this.打开OToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.打开OToolStripMenuItem.Name = "打开OToolStripMenuItem";
            this.打开OToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
            this.打开OToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.打开OToolStripMenuItem.Text = "打开(O)...";
            this.打开OToolStripMenuItem.Click += new System.EventHandler(this.打开OToolStripMenuItem_Click);
            // 
            // 保存SToolStripMenuItem
            // 
            this.保存SToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.保存SToolStripMenuItem.Name = "保存SToolStripMenuItem";
            this.保存SToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.保存SToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.保存SToolStripMenuItem.Text = "保存(S)";
            this.保存SToolStripMenuItem.Click += new System.EventHandler(this.保存SToolStripMenuItem_Click);
            // 
            // 另存为AToolStripMenuItem
            // 
            this.另存为AToolStripMenuItem.Name = "另存为AToolStripMenuItem";
            this.另存为AToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.另存为AToolStripMenuItem.Text = "另存为(A)...";
            this.另存为AToolStripMenuItem.Click += new System.EventHandler(this.另存为AToolStripMenuItem_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(171, 6);
            // 
            // 页面设置UToolStripMenuItem
            // 
            this.页面设置UToolStripMenuItem.Name = "页面设置UToolStripMenuItem";
            this.页面设置UToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.页面设置UToolStripMenuItem.Text = "页面设置(U)...";
            this.页面设置UToolStripMenuItem.Click += new System.EventHandler(this.页面设置UToolStripMenuItem_Click);
            // 
            // 打印PToolStripMenuItem
            // 
            this.打印PToolStripMenuItem.Name = "打印PToolStripMenuItem";
            this.打印PToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)));
            this.打印PToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.打印PToolStripMenuItem.Text = "打印(P)...";
            this.打印PToolStripMenuItem.Click += new System.EventHandler(this.打印PToolStripMenuItem_Click);
            // 
            // toolStripMenuItem1
            // 
            this.toolStripMenuItem1.Name = "toolStripMenuItem1";
            this.toolStripMenuItem1.Size = new System.Drawing.Size(171, 6);
            // 
            // 退出XToolStripMenuItem
            // 
            this.退出XToolStripMenuItem.Name = "退出XToolStripMenuItem";
            this.退出XToolStripMenuItem.Size = new System.Drawing.Size(174, 22);
            this.退出XToolStripMenuItem.Text = "退出(X)";
            this.退出XToolStripMenuItem.Click += new System.EventHandler(this.退出XToolStripMenuItem_Click);
            // 
            // 编辑EToolStripMenuItem
            // 
            this.编辑EToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.撤消UToolStripMenuItem,
            this.toolStripSeparator3,
            this.剪切TToolStripMenuItem,
            this.复制CToolStripMenuItem,
            this.粘贴PToolStripMenuItem,
            this.删除LToolStripMenuItem,
            this.toolStripMenuItem2,
            this.查找FToolStripMenuItem,
            this.查找下一个NToolStripMenuItem,
            this.替换RToolStripMenuItem,
            this.转到GToolStripMenuItem,
            this.toolStripMenuItem3,
            this.全选AToolStripMenuItem,
            this.时间日期DToolStripMenuItem});
            this.编辑EToolStripMenuItem.Name = "编辑EToolStripMenuItem";
            this.编辑EToolStripMenuItem.Size = new System.Drawing.Size(59, 21);
            this.编辑EToolStripMenuItem.Text = "编辑(E)";
            this.编辑EToolStripMenuItem.Click += new System.EventHandler(this.编辑EToolStripMenuItem_Click);
            // 
            // 撤消UToolStripMenuItem
            // 
            this.撤消UToolStripMenuItem.Name = "撤消UToolStripMenuItem";
            this.撤消UToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Z)));
            this.撤消UToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.撤消UToolStripMenuItem.Text = "撤消(U)";
            this.撤消UToolStripMenuItem.Click += new System.EventHandler(this.撤消UToolStripMenuItem_Click);
            // 
            // toolStripSeparator3
            // 
            this.toolStripSeparator3.Name = "toolStripSeparator3";
            this.toolStripSeparator3.Size = new System.Drawing.Size(172, 6);
            // 
            // 剪切TToolStripMenuItem
            // 
            this.剪切TToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.剪切TToolStripMenuItem.Name = "剪切TToolStripMenuItem";
            this.剪切TToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.X)));
            this.剪切TToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.剪切TToolStripMenuItem.Text = "剪切(T)";
            this.剪切TToolStripMenuItem.Click += new System.EventHandler(this.剪切TToolStripMenuItem_Click);
            // 
            // 复制CToolStripMenuItem
            // 
            this.复制CToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.复制CToolStripMenuItem.Name = "复制CToolStripMenuItem";
            this.复制CToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.C)));
            this.复制CToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.复制CToolStripMenuItem.Text = "复制(C)";
            this.复制CToolStripMenuItem.Click += new System.EventHandler(this.复制CToolStripMenuItem_Click);
            // 
            // 粘贴PToolStripMenuItem
            // 
            this.粘贴PToolStripMenuItem.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.粘贴PToolStripMenuItem.Name = "粘贴PToolStripMenuItem";
            this.粘贴PToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.V)));
            this.粘贴PToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.粘贴PToolStripMenuItem.Text = "粘贴(P)";
            this.粘贴PToolStripMenuItem.Click += new System.EventHandler(this.粘贴PToolStripMenuItem_Click);
            // 
            // 删除LToolStripMenuItem
            // 
            this.删除LToolStripMenuItem.Name = "删除LToolStripMenuItem";
            this.删除LToolStripMenuItem.ShortcutKeys = System.Windows.Forms.Keys.Delete;
            this.删除LToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.删除LToolStripMenuItem.Text = "删除(L)";
            this.删除LToolStripMenuItem.Click += new System.EventHandler(this.删除LToolStripMenuItem_Click);
            // 
            // toolStripMenuItem2
            // 
            this.toolStripMenuItem2.Name = "toolStripMenuItem2";
            this.toolStripMenuItem2.Size = new System.Drawing.Size(172, 6);
            // 
            // 查找FToolStripMenuItem
            // 
            this.查找FToolStripMenuItem.Name = "查找FToolStripMenuItem";
            this.查找FToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.F)));
            this.查找FToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.查找FToolStripMenuItem.Text = "查找(F)...";
            this.查找FToolStripMenuItem.Click += new System.EventHandler(this.查找FToolStripMenuItem_Click);
            // 
            // 查找下一个NToolStripMenuItem
            // 
            this.查找下一个NToolStripMenuItem.Name = "查找下一个NToolStripMenuItem";
            this.查找下一个NToolStripMenuItem.ShortcutKeys = System.Windows.Forms.Keys.F3;
            this.查找下一个NToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.查找下一个NToolStripMenuItem.Text = "查找下一个(N)";
            this.查找下一个NToolStripMenuItem.Click += new System.EventHandler(this.查找下一个NToolStripMenuItem_Click);
            // 
            // 替换RToolStripMenuItem
            // 
            this.替换RToolStripMenuItem.Name = "替换RToolStripMenuItem";
            this.替换RToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.H)));
            this.替换RToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.替换RToolStripMenuItem.Text = "替换(R)...";
            this.替换RToolStripMenuItem.Click += new System.EventHandler(this.替换RToolStripMenuItem_Click);
            // 
            // 转到GToolStripMenuItem
            // 
            this.转到GToolStripMenuItem.Name = "转到GToolStripMenuItem";
            this.转到GToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.G)));
            this.转到GToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.转到GToolStripMenuItem.Text = "转到(G)...";
            this.转到GToolStripMenuItem.Click += new System.EventHandler(this.转到GToolStripMenuItem_Click);
            // 
            // toolStripMenuItem3
            // 
            this.toolStripMenuItem3.Name = "toolStripMenuItem3";
            this.toolStripMenuItem3.Size = new System.Drawing.Size(172, 6);
            // 
            // 全选AToolStripMenuItem
            // 
            this.全选AToolStripMenuItem.Name = "全选AToolStripMenuItem";
            this.全选AToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.A)));
            this.全选AToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.全选AToolStripMenuItem.Text = "全选(A)";
            this.全选AToolStripMenuItem.Click += new System.EventHandler(this.全选AToolStripMenuItem_Click);
            // 
            // 时间日期DToolStripMenuItem
            // 
            this.时间日期DToolStripMenuItem.Name = "时间日期DToolStripMenuItem";
            this.时间日期DToolStripMenuItem.ShortcutKeys = System.Windows.Forms.Keys.F5;
            this.时间日期DToolStripMenuItem.Size = new System.Drawing.Size(175, 22);
            this.时间日期DToolStripMenuItem.Text = "时间/日期(D)";
            this.时间日期DToolStripMenuItem.Click += new System.EventHandler(this.时间日期DToolStripMenuItem_Click);
            // 
            // 格式OToolStripMenuItem
            // 
            this.格式OToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.自动换行WToolStripMenuItem,
            this.字体FToolStripMenuItem});
            this.格式OToolStripMenuItem.Name = "格式OToolStripMenuItem";
            this.格式OToolStripMenuItem.Size = new System.Drawing.Size(62, 21);
            this.格式OToolStripMenuItem.Text = "格式(O)";
            // 
            // 自动换行WToolStripMenuItem
            // 
            this.自动换行WToolStripMenuItem.Name = "自动换行WToolStripMenuItem";
            this.自动换行WToolStripMenuItem.Size = new System.Drawing.Size(144, 22);
            this.自动换行WToolStripMenuItem.Text = "自动换行(W)";
            this.自动换行WToolStripMenuItem.Click += new System.EventHandler(this.自动换行WToolStripMenuItem_Click);
            // 
            // 字体FToolStripMenuItem
            // 
            this.字体FToolStripMenuItem.Name = "字体FToolStripMenuItem";
            this.字体FToolStripMenuItem.Size = new System.Drawing.Size(144, 22);
            this.字体FToolStripMenuItem.Text = "字体(F)...";
            this.字体FToolStripMenuItem.Click += new System.EventHandler(this.字体FToolStripMenuItem_Click);
            // 
            // 查看VToolStripMenuItem
            // 
            this.查看VToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripSeparator2,
            this.状态栏SToolStripMenuItem});
            this.查看VToolStripMenuItem.Name = "查看VToolStripMenuItem";
            this.查看VToolStripMenuItem.Size = new System.Drawing.Size(60, 21);
            this.查看VToolStripMenuItem.Text = "查看(V)";
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(124, 6);
            // 
            // 状态栏SToolStripMenuItem
            // 
            this.状态栏SToolStripMenuItem.Checked = true;
            this.状态栏SToolStripMenuItem.CheckState = System.Windows.Forms.CheckState.Checked;
            this.状态栏SToolStripMenuItem.Name = "状态栏SToolStripMenuItem";
            this.状态栏SToolStripMenuItem.Size = new System.Drawing.Size(127, 22);
            this.状态栏SToolStripMenuItem.Text = "状态栏(S)";
            this.状态栏SToolStripMenuItem.Click += new System.EventHandler(this.状态栏SToolStripMenuItem_Click);
            // 
            // 帮助HToolStripMenuItem
            // 
            this.帮助HToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.查看帮助HToolStripMenuItem,
            this.关于记事本AToolStripMenuItem});
            this.帮助HToolStripMenuItem.Name = "帮助HToolStripMenuItem";
            this.帮助HToolStripMenuItem.Size = new System.Drawing.Size(61, 21);
            this.帮助HToolStripMenuItem.Text = "帮助(H)";
            // 
            // 查看帮助HToolStripMenuItem
            // 
            this.查看帮助HToolStripMenuItem.Name = "查看帮助HToolStripMenuItem";
            this.查看帮助HToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.查看帮助HToolStripMenuItem.Text = "查看帮助(H)";
            this.查看帮助HToolStripMenuItem.Click += new System.EventHandler(this.查看帮助HToolStripMenuItem_Click);
            // 
            // 关于记事本AToolStripMenuItem
            // 
            this.关于记事本AToolStripMenuItem.Name = "关于记事本AToolStripMenuItem";
            this.关于记事本AToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.关于记事本AToolStripMenuItem.Text = "关于记事本(A)";
            this.关于记事本AToolStripMenuItem.Click += new System.EventHandler(this.关于记事本AToolStripMenuItem_Click);
            // 
            // richTextBoxBoard
            // 
            this.richTextBoxBoard.Dock = System.Windows.Forms.DockStyle.Fill;
            this.richTextBoxBoard.Location = new System.Drawing.Point(0, 25);
            this.richTextBoxBoard.Name = "richTextBoxBoard";
            this.richTextBoxBoard.Size = new System.Drawing.Size(566, 268);
            this.richTextBoxBoard.TabIndex = 1;
            this.richTextBoxBoard.Text = "";
            this.richTextBoxBoard.WordWrap = false;
            this.richTextBoxBoard.SelectionChanged += new System.EventHandler(this.richTextBoxBoard_SelectionChanged);
            this.richTextBoxBoard.TextChanged += new System.EventHandler(this.richTextBoxBoard_TextChanged);
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            // 
            // printDialog1
            // 
            this.printDialog1.UseEXDialog = true;
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1,
            this.toolStripStatusLabel2});
            this.statusStrip1.Location = new System.Drawing.Point(0, 271);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(566, 22);
            this.statusStrip1.TabIndex = 2;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(551, 17);
            this.toolStripStatusLabel1.Spring = true;
            // 
            // toolStripStatusLabel2
            // 
            this.toolStripStatusLabel2.Name = "toolStripStatusLabel2";
            this.toolStripStatusLabel2.Size = new System.Drawing.Size(0, 17);
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(566, 293);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.richTextBoxBoard);
            this.Controls.Add(this.menuStrip1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "Main";
            this.Text = "记事本";
            this.Load += new System.EventHandler(this.Main_Load);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Main_FormClosing);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem 文件FToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 新建NToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 打开OToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 保存SToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 另存为AToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem 页面设置UToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 打印PToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 编辑EToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 撤消UToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator3;
        private System.Windows.Forms.ToolStripMenuItem 剪切TToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 复制CToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 粘贴PToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripMenuItem1;
        private System.Windows.Forms.ToolStripMenuItem 退出XToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 删除LToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripMenuItem2;
        private System.Windows.Forms.ToolStripMenuItem 查找FToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 查找下一个NToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 替换RToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 转到GToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripMenuItem3;
        private System.Windows.Forms.ToolStripMenuItem 全选AToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 时间日期DToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 格式OToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 自动换行WToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 字体FToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 查看VToolStripMenuItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripMenuItem 状态栏SToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 帮助HToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 查看帮助HToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem 关于记事本AToolStripMenuItem;
        public System.Windows.Forms.RichTextBox richTextBoxBoard;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.PageSetupDialog pageSetupDialog1;
        private System.Drawing.Printing.PrintDocument printDocument1;
        private System.Windows.Forms.PrintDialog printDialog1;
        private System.Windows.Forms.FontDialog fontDialog1;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel1;
        private System.Windows.Forms.ToolStripStatusLabel toolStripStatusLabel2;
    }
}

