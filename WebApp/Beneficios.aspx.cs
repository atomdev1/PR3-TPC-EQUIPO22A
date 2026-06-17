using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Beneficios : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            // Solo Administrador: configura los umbrales que reparten cupones.
            if (u.Rol != RolUsuario.Administrador)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
                CargarBeneficios();
        }

        private void CargarBeneficios()
        {
            NegocioBeneficios nBeneficios = new NegocioBeneficios();
            List<BeneficioFidelidad> beneficios = nBeneficios.ObtenerTodos();

            rptBeneficios.DataSource = beneficios;
            rptBeneficios.DataBind();
        }

        // Alta: limpia el formulario, deja todo en estado inicial y abre el modal.
        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            hfIdBeneficio.Value        = "";
            txtNombre.Text             = "";
            txtReservasRequeridas.Text = "";
            ddlTipoDescuento.SelectedValue = "1";
            txtValorDescuento.Text     = "";
            txtDiasValidez.Text        = "";
            txtDescripcion.Text        = "";
            lblError.Visible           = false;

            AplicarEstadoValor();
            AbrirModal("Nuevo beneficio");
        }

        // Confirma la baja: ejecuta la baja lógica del id guardado y oculta el panel.
        protected void btnConfirmarBaja_Click(object sender, EventArgs e)
        {
            new NegocioBeneficios().BajaLogica(int.Parse(hfBajaId.Value));
            pnlConfirmarBaja.Visible = false;
            CargarBeneficios();
        }

        protected void btnCancelarBaja_Click(object sender, EventArgs e)
        {
            pnlConfirmarBaja.Visible = false;
        }

        // "Reserva gratis" no lleva valor: se deshabilita el campo (el server igual fuerza NULL).
        // Corre por AutoPostBack dentro del UpdatePanel, así el modal no se cierra.
        protected void ddlTipoDescuento_SelectedIndexChanged(object sender, EventArgs e)
        {
            AplicarEstadoValor();
        }

        private void AplicarEstadoValor()
        {
            bool esReservaGratis = ddlTipoDescuento.SelectedValue == "2";
            txtValorDescuento.Enabled = !esReservaGratis;
            if (esReservaGratis) txtValorDescuento.Text = "";
        }

        private void AbrirModal(string titulo)
        {
            string script =
                "var lbl = document.getElementById('modalBeneficioLabel'); if (lbl) lbl.textContent = '" + titulo + "';" +
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalBeneficio')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalBeneficio", script, true);
        }

        protected void rptBeneficios_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idBeneficio = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                BeneficioFidelidad b = new NegocioBeneficios().ObtenerPorId(idBeneficio);
                if (b == null) return;

                hfIdBeneficio.Value            = b.IdBeneficio.ToString();
                txtNombre.Text                 = b.Nombre;
                txtReservasRequeridas.Text     = b.ReservasRequeridas.ToString();
                ddlTipoDescuento.SelectedValue = ((int)b.TipoDescuento).ToString();
                txtValorDescuento.Text         = b.ValorDescuento.HasValue ? b.ValorDescuento.Value.ToString() : "";
                txtDiasValidez.Text            = b.DiasValidez.HasValue ? b.DiasValidez.Value.ToString() : "";
                txtDescripcion.Text            = b.Descripcion;

                AplicarEstadoValor();
                AbrirModal("Editar beneficio");
            }
            else if (e.CommandName == "Baja")
            {
                // No se da de baja directo: se pide confirmación con un panel.
                BeneficioFidelidad b = new NegocioBeneficios().ObtenerPorId(idBeneficio);
                hfBajaId.Value = idBeneficio.ToString();
                lblConfirmarBaja.Text = "¿Dar de baja el beneficio \"" + (b != null ? b.Nombre : "") + "\"?";
                pnlConfirmarBaja.Visible = true;
            }
            else if (e.CommandName == "Reactivar")
            {
                new NegocioBeneficios().Reactivar(idBeneficio);
                CargarBeneficios();
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            TipoDescuento tipo = (TipoDescuento)int.Parse(ddlTipoDescuento.SelectedValue);

            // ReservaGratis no lleva valor; el resto sí es obligatorio
            decimal? valorDescuento;
            if (tipo == TipoDescuento.ReservaGratis)
            {
                valorDescuento = null;
            }
            else if (string.IsNullOrEmpty(txtValorDescuento.Text))
            {
                MostrarError("El valor del descuento es obligatorio para este tipo.");
                return;
            }
            else
            {
                valorDescuento = decimal.Parse(txtValorDescuento.Text);
            }

            BeneficioFidelidad beneficio = new BeneficioFidelidad
            {
                Nombre = txtNombre.Text.Trim(),
                ReservasRequeridas = int.Parse(txtReservasRequeridas.Text),
                TipoDescuento = tipo,
                ValorDescuento = valorDescuento,
                DiasValidez = string.IsNullOrEmpty(txtDiasValidez.Text) ? (int?)null : int.Parse(txtDiasValidez.Text),
                Descripcion = txtDescripcion.Text.Trim()
            };

            try
            {
                NegocioBeneficios nBeneficios = new NegocioBeneficios();
                if (string.IsNullOrEmpty(hfIdBeneficio.Value))
                {
                    nBeneficios.Agregar(beneficio);
                }
                else
                {
                    beneficio.IdBeneficio = int.Parse(hfIdBeneficio.Value);
                    nBeneficios.Modificar(beneficio);
                }
                Response.Redirect("Beneficios.aspx");
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                // violación del UNIQUE de ReservasRequeridas (un beneficio por umbral)
                MostrarError("Ya existe un beneficio para esa cantidad de reservas requeridas. Usá otro umbral.");
            }
        }

        private void MostrarError(string mensaje)
        {
            lblError.Text = mensaje;
            lblError.Visible = true;

            // el modal se cierra con el postback, hay que reabrirlo para que se vea el error
            string titulo = string.IsNullOrEmpty(hfIdBeneficio.Value) ? "Nuevo beneficio" : "Editar beneficio";
            AbrirModal(titulo);
        }

        // Helpers de presentación (propios: un Beneficio no es un Cupón)

        protected string GetBadgeSymbol(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.Porcentaje ? "%" : "★";
        }

        protected string GetTipoNombre(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.ReservaGratis ? "Reserva gratis" : "Descuento en reserva";
        }

        protected string FormatearValor(object tipoDescuentoObj, object valorObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            if (tipo == TipoDescuento.ReservaGratis) return "GRATIS";
            if (valorObj == null || valorObj == DBNull.Value) return "-";
            decimal valor = Convert.ToDecimal(valorObj);
            return valor == 100 ? "100% OFF" : $"{valor:0}% OFF";
        }

        protected string FormatearValidez(object diasObj)
        {
            if (diasObj == null || diasObj == DBNull.Value) return "📅 Sin vencimiento";
            return "📅 Vence a los " + diasObj + " días";
        }

        protected string GetEstadoNombre(object activoObj)
        {
            return (bool)activoObj ? "Activo" : "Inactivo";
        }

        protected string GetEstadoBadgeClass(object activoObj)
        {
            return (bool)activoObj ? "tag-ok" : "tag-neutral";
        }
    }
}
