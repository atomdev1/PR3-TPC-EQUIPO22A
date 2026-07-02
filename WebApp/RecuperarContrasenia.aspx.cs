using Dominio;
using Negocio;
using System;

namespace WebApp
{
    public partial class RecuperarContrasenia : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnVerificar_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string dni = txtDNI.Text.Trim();
            string email = txtEmail.Text.Trim();
            DateTime fechaNacimiento;

            if (!DateTime.TryParse(txtFechaNacimiento.Text, out fechaNacimiento))
            {
                MostrarError("Ingresá una fecha de nacimiento válida.");
                return;
            }

            Usuario usuario = new NegocioUsuarios().VerificarIdentidad(dni, email, fechaNacimiento);

            if (usuario == null)
            {
                MostrarError("Los datos ingresados no coinciden con ningún usuario. Verificá el DNI, el email y la fecha de nacimiento.");
                return;
            }

            hfIdUsuario.Value = usuario.IdUsuario.ToString();
            pnlVerificar.Visible = false;
            pnlNuevaPassword.Visible = true;
            lblError.Visible = false;
        }

        protected void btnGuardarPassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (string.IsNullOrEmpty(hfIdUsuario.Value))
            {
                MostrarError("Tu sesión de verificación expiró. Volvé a intentarlo.");
                pnlVerificar.Visible = true;
                pnlNuevaPassword.Visible = false;
                return;
            }


            int idUsuario = int.Parse(hfIdUsuario.Value);
            new NegocioUsuarios().ActualizarPassword(idUsuario, txtNuevaPassword.Text);

            pnlNuevaPassword.Visible = false;
            lblOk.Text = "Tu contraseña se actualizó correctamente. Ya podés iniciar sesión.";
            lblOk.Visible = true;
        }

        private void MostrarError(string mensaje)
        {
            lblError.Text = mensaje;
            lblError.Visible = true;
        }
    }
}
