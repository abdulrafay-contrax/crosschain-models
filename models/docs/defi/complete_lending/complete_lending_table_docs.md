{% docs complete_lending_borrows_table_doc %}

A comprehensive table that contains all blockchain and platform specific borrows. This table contains borrows from Arbitrum, Avalanche, Base, BSC, Gnosis, Ethereum, Optimism, and Polygon. In order to borrow assets, a user must first deposit their preferred asset and amount as collateral.


{% enddocs %}

{% docs complete_lending_deposits_table_doc %}

A comprehensive table that contains all blockchain and platform specific deposits. This table contains deposit eventss across Arbitrum, Avalanche, Base, BSC, Gnosis, Ethereum, Optimism, and Polygon. A user deposits their preferred asset and amount. After depositing, users earn passive income based on the market borrowing demand. Additionally, depositing allows users to borrow by using their deposited assets as a collateral. Any interest earned by depositing funds helps offset the interest rate accumulated by borrowing.

{% enddocs %}

{% docs complete_lending_flashloans_table_doc %}

A comprehensive table that contains all blockchain and platform specific flashloans. This table contains deposit events across Arbitrum, Avalanche, Base, BSC, Gnosis, Ethereum, Optimism, and Polygon. Flash loans are a feature designed for developers, due to the technical knowledge required to execute one. Flash Loans allow you to borrow any available amount of assets without providing any collateral, as long as the liquidity is returned to the protocol within one block transaction.  

{% enddocs %}

{% docs complete_lending_liquidations_table_doc %}

A comprehensive table that contains all blockchain and platform specific liquidations. This table contains liquidation events in which a borrower's collateral asset is liquidated across Arbitrum, Avalanche, Base, BSC, Gnosis, Ethereum, Optimism, and Polygon. Liquidations occur when a borrower's health factor goes below 1 due to their collateral value not properly covering their loan/debt value. This might happen when the collateral decreases in value or the borrowed debt increases in value against each other. This collateral vs loan value ratio is shown in the health factor. In a liquidation, up to 50% of a borrower's debt is repaid and that value + liquidation fee is taken from the collateral available, so after a liquidation the amount liquidated from one's debt is repaid. 

{% enddocs %}

{% docs complete_lending_repayments_table_doc %}

A comprehensive table that contains events in which a borrower repays their loan (debt) across Arbitrum, Avalanche, Base, BSC, Gnosis, Ethereum, Optimism, and Polygon. Loans are repaid in the same asset borrowed, plus accrued interest. Borrowers can pay back their loan based on the USD price as they can borrow any of the available stable coins (USDC, DAI, USDT, etc.).

{% enddocs %}

{% docs complete_lending_withdraws_table_doc %}

A comprehensive table contains transactions in which a user withdraws liquidity across Arbitrum, Avalanche, Base, BSC, Gnosis, Ethereum, Optimism, and Polygon. Users need to make sure there is enough liquidity (not borrowed) in order to withdraw, if this is not the case, users need to wait for more liquidity from depositors or borrowers repaying.

{% enddocs %}