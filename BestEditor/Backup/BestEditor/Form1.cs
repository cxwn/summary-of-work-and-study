using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace BestEditor
{
    public partial class Main : Form
    {
        private bool isTextChanged;
        private string path;//记录文件路径（刚新建的文件路径为""，打开的文件路径为原路径）

        public Main()
        {
            InitializeComponent();
            this.Text = "无标题 - 记事本";
            path = "";
        }

        /// <summary>
        /// 初始化窗体时调用
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Main_Load(object sender, EventArgs e)
        {
            //初始化，撤销、剪切、复制、删除 不可用
            撤消UToolStripMenuItem.Enabled = false;
            剪切TToolStripMenuItem.Enabled = false;
            复制CToolStripMenuItem.Enabled = false;
            删除LToolStripMenuItem.Enabled = false;

            if (richTextBoxBoard.Equals(""))
            {
                查找FToolStripMenuItem.Enabled = false;
                查找下一个NToolStripMenuItem.Enabled = false;
            }
            else
            {
                查找FToolStripMenuItem.Enabled = true;
                查找下一个NToolStripMenuItem.Enabled = true;
            }

            if (Clipboard.ContainsText())
                粘贴PToolStripMenuItem.Enabled = true;
            else
                粘贴PToolStripMenuItem.Enabled = false;

            toolStripStatusLabel2.Text = "第 1 行，第 1 列";
        }

        private void 新建NToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //如果输入框文字发生变动
            if (isTextChanged)
            {
                saveFileDialog1.FileName = "*.txt";
                DialogResult dr = MessageBox.Show("是否将更改保存到 " + this.Text + "?", "记事本", 
                    MessageBoxButtons.YesNoCancel);
                if (dr == DialogResult.Yes)
                {
                    //获取或设置指定要在 SaveFileDialog 中显示的文件类型和说明的筛选器字符串
                    saveFileDialog1.Filter = @"文本文档(*.txt)|*.txt|所有格式|*.txt;*.doc;*.cs;*.rtf;*.sln";
                    if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                    {
                        richTextBoxBoard.SaveFile(saveFileDialog1.FileName, RichTextBoxStreamType.PlainText);
                        richTextBoxBoard.Text = "";
                        path = "";
                    }
                }
                else if(dr == DialogResult.No)
                {
                    richTextBoxBoard.Text = "";
                    path = "";
                }
            }
            else
            {
                richTextBoxBoard.Text = "";
                this.Text = "无标题 - 记事本";
                path = "";
            }
        }

        /// <summary>
        /// 输入框发生变化时触发
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void richTextBoxBoard_TextChanged(object sender, EventArgs e)
        {
            isTextChanged = true;
        }

        private void 打开OToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (isTextChanged)
            {
                saveFileDialog1.FileName = "*.txt";
                DialogResult dr = MessageBox.Show("是否将更改保存到 " + this.Text + "?", "记事本",
                    MessageBoxButtons.YesNoCancel);
                if (dr == DialogResult.Yes)
                {
                    //获取或设置指定要在 SaveFileDialog 中显示的文件类型和说明的筛选器字符串
                    saveFileDialog1.Filter = @"文本文档(*.txt)|*.txt|所有格式|*.txt;*.doc;*.cs;*.rtf;*.sln";
                    if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                    {
                        richTextBoxBoard.SaveFile(saveFileDialog1.FileName, RichTextBoxStreamType.PlainText);
                        Text = saveFileDialog1.FileName.Substring(saveFileDialog1.FileName.LastIndexOf("\\")+1)+
                            " - 记事本";
                    }
                }
            }

            openFileDialog1.FileName = "";

            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                path = openFileDialog1.FileName;
                Text = path.Substring(path.LastIndexOf("\\") + 1) + " - 记事本";
                Console.WriteLine("path={0}",path);
                richTextBoxBoard.LoadFile(path, RichTextBoxStreamType.PlainText);
                isTextChanged = false;
            }
        }

        private void 保存SToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!("".Equals(path)))
            {
                richTextBoxBoard.SaveFile(path, RichTextBoxStreamType.PlainText);
                isTextChanged = false;
            }
            else
            {
                saveFileDialog1.Filter = @"文本文档(*.txt)|*.txt|所有格式|*.txt;*.doc;*.cs;*.rtf;*.sln";
                if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                {
                    richTextBoxBoard.SaveFile(saveFileDialog1.FileName, RichTextBoxStreamType.PlainText);
                    path = saveFileDialog1.FileName;
                    this.Text = path.Substring(path.LastIndexOf("\\") + 1) + " - 记事本";
                    isTextChanged = false;
                }
            }
        }

        private void 另存为AToolStripMenuItem_Click(object sender, EventArgs e)
        {
            saveFileDialog1.Filter = @"文本文档(*.txt)|*.txt|所有格式|*.txt;*.doc;*.cs;*.rtf;*.sln";
            if (saveFileDialog1.ShowDialog() == DialogResult.OK)
            {
                richTextBoxBoard.SaveFile(saveFileDialog1.FileName, RichTextBoxStreamType.PlainText);
                path = saveFileDialog1.FileName;
                this.Text = path.Substring(path.LastIndexOf("\\") + 1) + " - 记事本";
                isTextChanged = false;
            }
        }

        private void 页面设置UToolStripMenuItem_Click(object sender, EventArgs e)
        {
            pageSetupDialog1.Document = printDocument1;
            pageSetupDialog1.ShowDialog();
        }

        private void 打印PToolStripMenuItem_Click(object sender, EventArgs e)
        {
            printDialog1.Document = printDocument1;
            printDialog1.ShowDialog();
        }

        private void 退出XToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void 撤消UToolStripMenuItem_Click(object sender, EventArgs e)
        {
            richTextBoxBoard.Undo();
        }

        private void 编辑EToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (richTextBoxBoard.CanUndo)
                撤消UToolStripMenuItem.Enabled = true;

            if (richTextBoxBoard.SelectionLength > 0)
            {
                剪切TToolStripMenuItem.Enabled = true;
                复制CToolStripMenuItem.Enabled = true;
                删除LToolStripMenuItem.Enabled = true;
            }
            else
            {
                剪切TToolStripMenuItem.Enabled = false;
                复制CToolStripMenuItem.Enabled = false;
                删除LToolStripMenuItem.Enabled = false;
            }

            if (richTextBoxBoard.Equals(""))
            {
                查找FToolStripMenuItem.Enabled = false;
                查找下一个NToolStripMenuItem.Enabled = false;
            }
            else
            {
                查找FToolStripMenuItem.Enabled = true;
                查找下一个NToolStripMenuItem.Enabled = true;
            }

            if (Clipboard.ContainsText())
                粘贴PToolStripMenuItem.Enabled = true;
            else
                粘贴PToolStripMenuItem.Enabled = false;
        }

        private void 剪切TToolStripMenuItem_Click(object sender, EventArgs e)
        {
            richTextBoxBoard.Cut();
        }

        private void 复制CToolStripMenuItem_Click(object sender, EventArgs e)
        {
            richTextBoxBoard.Copy();
        }

        private void 粘贴PToolStripMenuItem_Click(object sender, EventArgs e)
        {
            richTextBoxBoard.Paste();
        }

        private void 删除LToolStripMenuItem_Click(object sender, EventArgs e)
        {
            richTextBoxBoard.SelectedText = "";
        }

        /// <summary>
        /// 不同窗体之间通讯
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void 查找FToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Search search = new Search();
            search.Owner = this;
            search.Show();
        }

        private void 查找下一个NToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Search search = new Search();
            search.Owner = this;
            search.Show();
        }

        private void 替换RToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Change change = new Change();
            change.Owner = this;
            change.Show();
        }

        private void 转到GToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Goto gt = new Goto();
            gt.Owner = this;
            gt.Show();
        }

        private void 全选AToolStripMenuItem_Click(object sender, EventArgs e)
        {
            richTextBoxBoard.SelectAll();
        }

        private void 时间日期DToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string front = richTextBoxBoard.Text.Substring(0, richTextBoxBoard.SelectionStart);
            string back = richTextBoxBoard.Text.Substring(richTextBoxBoard.SelectionStart, 
                richTextBoxBoard.Text.Length - richTextBoxBoard.SelectionStart);
            richTextBoxBoard.Text = front + DateTime.Now.ToString() + back;
        }

        private void 自动换行WToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (richTextBoxBoard.WordWrap)
            {
                自动换行WToolStripMenuItem.Checked = false;
                richTextBoxBoard.WordWrap = false;
            }
            else
            {
                自动换行WToolStripMenuItem.Checked = true;
                richTextBoxBoard.WordWrap = true;
            }
        }

        private void 字体FToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fontDialog1.ShowDialog();
            richTextBoxBoard.SelectionFont = fontDialog1.Font;
        }

        /// <summary>
        /// 控制底部状态栏显示与否
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void 状态栏SToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (状态栏SToolStripMenuItem.Checked)
            {
                状态栏SToolStripMenuItem.Checked = false;
                statusStrip1.Visible = false;
            }
            else
            {
                状态栏SToolStripMenuItem.Checked = true;
                statusStrip1.Visible = true;
            }
        }

        /// <summary>
        /// 输入框光标位置变化时触发
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void richTextBoxBoard_SelectionChanged(object sender, EventArgs e)
        {
            string[] str = richTextBoxBoard.Text.Split('\r', '\n');
            int row = 1, column = 1, pos = richTextBoxBoard.SelectionStart;

            foreach(string s in str)
                Console.WriteLine(s);
            Console.WriteLine("pos={0}",pos);

            for (int i = 0; i < str.Length && pos - str[i].Length > 0; i++)
            {
                pos = pos - str[i].Length - 1;
                row = i + 2;
            }
            column = pos + 1;
            toolStripStatusLabel2.Text = "第 " + row + " 行，第 " + column + " 列";
        }

        private void 关于记事本AToolStripMenuItem_Click(object sender, EventArgs e)
        {
            AboutBox ab = new AboutBox();
            ab.Show();
        }

        private void 查看帮助HToolStripMenuItem_Click(object sender, EventArgs e)
        {
            //调用系统内部的notepad.chm文件
        }

        /// <summary>
        /// 点击窗体右上角关闭按钮触发
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Main_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (isTextChanged)
            {
                if (!("".Equals(path)))
                {
                    DialogResult dr = MessageBox.Show("是否将更改保存到"+path+"?","记事本",
                        MessageBoxButtons.YesNoCancel);
                    if (dr == DialogResult.Yes)
                        richTextBoxBoard.SaveFile(path, RichTextBoxStreamType.PlainText);
                    else if (dr == DialogResult.No)
                        e.Cancel = false;
                    else
                        e.Cancel = true;//不关闭
                }
                else
                {
                    DialogResult dr = MessageBox.Show("是否将更改保存到 无标题?", "记事本", 
                        MessageBoxButtons.YesNoCancel);
                    if (dr == DialogResult.Yes)
                    {
                        saveFileDialog1.Filter = @"文本文档(*.txt)|*.txt|所有格式|*.txt;*.doc;*.cs;*.rtf;*.sln";
                        if (saveFileDialog1.ShowDialog() == DialogResult.OK)
                            richTextBoxBoard.SaveFile(saveFileDialog1.FileName, RichTextBoxStreamType.PlainText);
                        else
                            e.Cancel = true;
                    }
                    else if (dr == DialogResult.No)
                        e.Cancel = false;
                    else
                        e.Cancel = true;
                }
            }
        }
    }
}