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
    public partial class Change : Form
    {
        private RichTextBox rtb = new RichTextBox();

        public Change()
        {
            InitializeComponent();
        }

        private void Change_Load(object sender, EventArgs e)
        {
            Main main = (Main)this.Owner;
            this.rtb = main.richTextBoxBoard;
            button1.Enabled = false;
            button2.Enabled = false;
            button3.Enabled = false;
        }

        /// <summary>
        /// 查找下一个
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button1_Click(object sender, EventArgs e)
        {
            string str = rtb.Text;
            string subSearch = textBox1.Text;
            string initString = subSearch;
            int pos = rtb.SelectionStart;

            if (!checkBox1.Checked)
            {
                str = str.ToLower();
                subSearch = subSearch.ToLower();
            }

            if (rtb.SelectionLength > 0)
                pos = pos + 1;
            if ((pos = str.IndexOf(subSearch, pos)) != -1)
            {
                rtb.Focus();
                rtb.SelectionStart = pos;
                rtb.SelectionLength = subSearch.Length;
            }
            else
                MessageBox.Show("找不到\"" + initString + "\"", "记事本", 
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            bool flag = textBox1.Text != "";
            button1.Enabled = flag;
            button2.Enabled = flag;
            button3.Enabled = flag;
        }

        /// <summary>
        /// 取消
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button4_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// 替换
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button2_Click(object sender, EventArgs e)
        {
            string str = rtb.Text;
            string subSearch = textBox1.Text;
            string initString = subSearch;
            string changeTo = textBox2.Text;
            string front;
            string dest;
            string back;
            int pos = rtb.SelectionStart;

            if (!checkBox1.Checked)
            {
                str = str.ToLower();
                subSearch = subSearch.ToLower();
            }

            if (rtb.SelectionLength > 0)
            {
                if (rtb.SelectedText.Equals(subSearch))
                {
                    //将文本框字符串分段，替换后再组合
                    front = rtb.Text.Substring(0,pos);
                    dest = changeTo;
                    back = rtb.Text.Substring(pos + subSearch.Length, rtb.Text.Length - pos - subSearch.Length);
                    rtb.Text = front + dest + back;
                }
                pos = pos + 1;
            }

            if ((pos = str.IndexOf(subSearch, pos)) != -1)
            {
                rtb.Focus();
                rtb.SelectionStart = pos;
                rtb.SelectionLength = subSearch.Length;
            }
            else
                MessageBox.Show("找不到\"" + initString + "\"", "记事本",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        /// <summary>
        /// 全部替换
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button3_Click(object sender, EventArgs e)
        {
            string str = rtb.Text;
            string subSearch = textBox1.Text;
            string changeTo = textBox2.Text;
            string front;
            string dest;
            string back;
            int pos = 0;

            if (!checkBox1.Checked)
            {
                str = str.ToLower();
                subSearch = subSearch.ToLower();
            }

            while ((pos=str.IndexOf(subSearch,pos))!=-1)
            {
                front = rtb.Text.Substring(0, pos);
                dest = changeTo;
                back = rtb.Text.Substring(pos + subSearch.Length, rtb.Text.Length - pos - subSearch.Length);
                rtb.Text = front + dest + back;
                if (!checkBox1.Checked)
                    str = rtb.Text.ToLower();
            }
        }
    }
}
