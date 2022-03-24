<%@ Control Language="C#" AutoEventWireup="True" CodeBehind="PDCStatSystem.ascx.cs" Inherits="PDC.UserControls.PDCStatSystem" %>


    <div class="PDCSysStatus rightMe">
<asp:UpdatePanel ID="AJAXUpdatePanelStatSch" runat="server">
<ContentTemplate> 
    <asp:LinkButton ID="lb_StatSYS_Toggle" runat="server" CssClass="headerButton" EnableViewState="False" onclick="Button_Toggle_Click">System</asp:LinkButton>
    <asp:Label ID="l_StatSYS_NUMBER_ON" runat="server" Text="Label" EnableViewState="False"></asp:Label>On
    <asp:Label ID="l_StatSYS_NUMBER_OFF" runat="server" Text="Label" EnableViewState="False"></asp:Label>Off


    <asp:Panel ID="p_StatusSystemDetail" runat="server" CssClass="" Visible="False">
        <div class="breaker_portlet">
            &nbsp;</div>
        <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource_GUI_SYS_STAT"
            GridLines="None" CssClass="PDCTbl" CellPadding="2" CellSpacing="1" 
            EnableViewState="False" AutoGenerateColumns="False">
            <RowStyle CssClass="PDCTblRow" Wrap="False" />
            <SelectedRowStyle CssClass="PDCTblSelRow" />
            <SortedAscendingHeaderStyle CssClass="sort_asc" />
            <SortedDescendingHeaderStyle CssClass="sort_desc" />
            <AlternatingRowStyle CssClass="PDCTblEvenRow" />
            <HeaderStyle CssClass="PDCTblHeader" />
            <Columns>
                <asp:BoundField DataField="PARAM_VAL_CHAR" HeaderText="System#" />
                <asp:BoundField DataField="SYS_STATUS" HeaderText="Status" />
            </Columns>
            <FooterStyle CssClass="PDCTblFooter" />
        </asp:GridView>
    </asp:Panel>

    <asp:Timer ID="TimerStatSch" runat="server" 
    Interval="<%$ AppSettings:DefaultPageReloadTimer %>" 
    ontick="TimerStatSch_Tick">
    </asp:Timer>
</ContentTemplate>
</asp:UpdatePanel> 

</div>
    <asp:SqlDataSource ID="SqlDataSource_GUI_SYS_STAT" runat="server" ConnectionString="<%$ ConnectionStrings:PDCOracleConnection.connectionString %>"
        
    ProviderName="<%$ ConnectionStrings:PDCOracleConnection.ProviderName %>" SelectCommand="PCKG_GUI.SP_GUI_HEADER_SYS_STAT"
        SelectCommandType="StoredProcedure" 
    OnSelected="SqlDataSource_Procedure_Selected" 
    onselecting="SqlDataSource_Procedure_Selecting" EnableViewState="False">
        <SelectParameters>
            <asp:Parameter Name="SYS_STATUS_OUT" Direction="Output" />
            <asp:Parameter Name="SYS_NUMBER_ON" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SYS_NUMBER_OFF" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="SELECTED_ENG_ID_IN" Direction="InputOutput" DefaultValue="0" DbType="String" Size="255" />
            <asp:Parameter Name="DEBUG_IN" Direction="Input" DefaultValue="0" DbType="String" />
            <asp:Parameter Name="EXIT_CD_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRMSG_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRCODE_OUT" Direction="Output" DbType="String" Size="255" />
            <asp:Parameter Name="ERRLINE_OUT" Direction="Output" DbType="String" Size="255" />
        </SelectParameters>
    </asp:SqlDataSource>