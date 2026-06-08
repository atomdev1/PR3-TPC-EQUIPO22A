using Dominio;
using Negocio;
using System;
using System.Data.SqlClient;

namespace WebApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected System.Web.UI.WebControls.Label lblError;
        protected System.Web.UI.WebControls.TextBox txtEmail;
        protected System.Web.UI.WebControls.TextBox txtPassword;
        protected System.Web.UI.WebControls.Button btnLogin;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] != null)
                Response.Redirect("~/Panel.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            Usuario usuario = new NegocioUsuarios().Login(email, password);

            if (usuario != null)
            {
                Session["usuario"] = usuario;
                Response.Redirect("~/Panel.aspx");
            }
            else
            {
                lblError.Text = "Email o contraseña incorrectos.";
                lblError.Visible = true;
            }
        }
    }
}