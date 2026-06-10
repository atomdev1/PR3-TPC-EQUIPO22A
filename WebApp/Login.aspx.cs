using Dominio;
using Negocio;
using System;
using System.Data.SqlClient;

namespace WebApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] != null)
                Response.Redirect("~/Dashboard.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            Usuario usuario = new NegocioUsuarios().Login(email, password);

            if (usuario != null)
            {
                Session["usuario"] = usuario;
                Response.Redirect("~/Dashboard.aspx");
            }
            else
            {
                lblError.Text = "Email o contraseña incorrectos.";
                lblError.Visible = true;
            }
        }
    }
}